//==============================================================================
//  Classic Domination 2   v2.0.9  (Two Teams)
//  Developed by Brian "Snake.PLiSKiN" Alexander
//  Special Thanks to Worlock, Carson "Dregs" Smith, 2L, sh0k, and Jalis
//  Based off the works of Jason "Captain Kewl" Yu and Epic Games, Inc.
//==============================================================================
Class cDOM2Game extends xDoubleDom
	config;

#exec OBJ LOAD FILE="CDOM-GameMeshes.usx"
#exec OBJ LOAD FILE="CDOMGameTextures.utx"

var const string CDOMVer;
var globalconfig  bool bUnlimitedTranslocator;  // Allow the Trans to be Unlimited.
var   config bool bAwardAdrenaline;     // Give the player 1 Adrenaline per each 1 team point they score.
var   config bool bDeviousBots;         // true = bot should use guile in hunting opponent (more expensive).
var   config bool bClassicTeamSymbols;  // Use the UT99 team symbols on the HUD to match the control points instead of UT2k4's new team symbols.
var   config bool bAdvertiseDDOM;       // Advertises the Server in the xDoubleDom servers inaddition to the Classic Domination servers.
var   config bool bAddCDOM2ServerName;  // Adds [cDOM] to the beginning of the Servers Name.
var   config bool bDebugMode;           // Dumps out extra debugging info to the system log.
var   config bool bExtraStatsLogging;   // When false, make 100% master server compatibile stat log files. If true, log extra info that may not be compatibile with the master server or other 3rd party stat systems.
var transient int CPs;                  // Cached # of control points so we dont have to figure it out each time.
var transient float Pts[2];             // Used to track when to dump out periodic Team stat scores.
var transient bool bObsoleteCP;
var() config string ClassicTeamSymbols[3]; // UT99 style team symbols.
var() config class<LocalMessage>  Message4Class; // cDOM4 Message class
var    array<xDomPoint> CDomPoints;      // The domination points in the level.
var    array<cDOM_PlayerReplicationInfo> domPRI;
var(LoadingHints) private localized array<string> CDomHints;
const CDPROPNUM = 2;
var localized string  CDomPropsDisplayText[CDPROPNUM], CDomPropDescText[CDPROPNUM];

static function PrecacheGameTextures(LevelInfo myLevel)
{
	class'xTeamGame'.static.PrecacheGameTextures(myLevel);
	myLevel.AddPrecacheMaterial(Material'CDOMGameTextures.textures.GraySkin2');
	myLevel.AddPrecacheMaterial(Material'CDOMGameTextures.textures.RedSkin2');
	myLevel.AddPrecacheMaterial(Material'CDOMGameTextures.textures.BlueSkin2');
	if ( class'cDOM2Game'.default.bClassicTeamSymbols )
	{
		myLevel.AddPrecacheMaterial( Texture'CDOMGameTextures.textures.RedTeamSymbol' );
		myLevel.AddPrecacheMaterial( Texture'CDOMGameTextures.textures.BlueTeamSymbol' );
		myLevel.AddPrecacheMaterial( Texture'CDOMGameTextures.textures.NeutralSymbol' );
	}
}

static function PrecacheGameStaticMeshes(LevelInfo myLevel)
{
	class'xDeathMatch'.static.PrecacheGameStaticMeshes(myLevel);

	myLevel.AddPrecacheStaticMesh(StaticMesh'CDOM-GameMeshes.ControlPoint.DomRed');
	myLevel.AddPrecacheStaticMesh(StaticMesh'CDOM-GameMeshes.ControlPoint.DomBlue');
	myLevel.AddPrecacheStaticMesh(StaticMesh'CDOM-GameMeshes.ControlPoint.DomNeutral');
	myLevel.AddPrecacheStaticMesh(StaticMesh'CDOM-GameMeshes.DOMpoint.Base');
	myLevel.AddPrecacheStaticMesh(StaticMesh'CDOM-GameMeshes.DOMpoint.BaseHidden');
}

/* OBSOLETE UpdateAnnouncements() - preload all announcer phrases used by this actor */
simulated function UpdateAnnouncements() {}

function int GetStatus(PlayerController Sender, Bot B)
{
	local name BotOrders;

	BotOrders = B.GetOrders();
	if (B.Pawn == None)
	{
		if ( (BotOrders == 'DEFEND') && (B.Squad.Size == 1) )
			return 0;
	}
	else if ( (B.Enemy == None) && (B.Squad.SquadObjective != None) && (B.Squad.SquadObjective.DefenderTeamIndex == B.Squad.Team.TeamIndex) && B.LineOfSightTo(B.Squad.SquadObjective) )
		return 11;
	else
		return Super(TeamGame).GetStatus(Sender, B);
}

static function int OrderToIndex(int Order)
{
	return Order;
}

/// <summary>
/// Unlock all vehicles for VDOM
/// </summary>
function RegisterVehicle(Vehicle V)
{
	Super.RegisterVehicle(V);
	V.bTeamLocked = Class'VDOM2Game'.default.bTeamLockedVehicles;
}

/// <summary>
/// Don't allow the Unlimited Translocator Mutator, because it is already built-in to the game.
/// </summary>
static function bool AllowMutator(string MutatorClassName)
{
	if ( MutatorClassName == "" )
		return False;
	if ( MutatorClassName ~= "ClassicDom.MutUnlimitedTrans" )
		return False;

	return super.AllowMutator(MutatorClassName);
}

/// <summary>
/// Special Thanks to UTComp for the idea
/// </summary>
function GetServerInfo( out ServerResponseLine ServerState )
{
	Super.GetServerInfo(ServerState);
	if ( bAdvertiseDDOM )
	{
		ServerState.GameType = Mid( string(Class'xDoubleDom'), InStr(string(Class'xDoubleDom'), ".")+1);
		ServerState.MapName  = Left(string(Level), InStr(string(Level), "."));
	}
	if ( bAddCDOM2ServerName )
		ServerState.ServerName = "[cDOM]"$GameReplicationInfo.ServerName;
}

// <EVENTS>

/// <summary>
/// Automatically add this to the servers ServerPackages list, if it is not already listed
/// </summary>
event InitGame(string Options, out string Error)
{
	Super(TeamGame).InitGame(Options, Error);
	AddToPackageMap("cDOM2");
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bUnlimitedTranslocator": return default.CDomPropDescText[0];
		case "bAwardAdrenaline": return default.CDomPropDescText[1];
	}
	return Super(TeamGame).GetDescriptionText(PropName);
}

event SetGrammar()
{
	LoadSRGrammar("cDOM");
}

// </EVENTS>

/// <summary>
/// Change Team Symbols to those used in UT99
/// </summary>
function InitTeamSymbols()
{
	if ( bClassicTeamSymbols )
	{
		if ( GameReplicationInfo.TeamSymbols[0] == None )
			GameReplicationInfo.TeamSymbols[0] = Texture(DynamicLoadObject(ClassicTeamSymbols[0], Class'Texture'));
		if ( GameReplicationInfo.TeamSymbols[1] == None )
			GameReplicationInfo.TeamSymbols[1] = Texture(DynamicLoadObject(ClassicTeamSymbols[1], Class'Texture'));

		GameReplicationInfo.TeamSymbolNotify();
	}
	else
		Super.InitTeamSymbols();
}

/// <summary>
/// if the map has ClassicDomPoint actors, flag them as bClassicControlPoint
/// </summary>
function PreBeginPlay()
{
	local NavigationPoint N;

	Super.PreBeginPlay();
	for (N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
		if ( N.IsA('ClassicDomPoint') )
			ClassicDomPoint(N).bClassicControlPoint = True;
}

/// <summary>
/// Hard Coded Collision size. This is to force a universal size for all maps and to prevent cheats.
/// </summary>
final function CheckCollisionSize( Actor A )
{
	if ( (A.CollisionRadius != 60.0000) || (A.CollisionHeight != 48.00000) )
		A.SetCollisionSize(60.0000, 48.0000);
}

function PostBeginPlay()
{
	local int i;
	local NavigationPoint N;

	Super(TeamGame).PostBeginPlay();
	Log("#####   LOADING cDOM2   [ver: "$CDOMVer$"]  #####",'cDOM2');
	i = 0;
	for (N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
	{
		if ( N.ClassIsChildOf(N.Class,Class'xDomPoint') )
		{
			if (bDebugMode) Log("## ClassIsChildOf: ["$N.Class$"], xDomPoint ##",'cDOM2');
			N.bHidden = False;
			CheckCollisionSize(N);
			CDomPoints[i] = xDomPoint(N);
			CDomPoints[i].ResetCount = ResetCount;
			/// <OLStats Hack>
			if ( i < 2 )
				xDomPoints[i] = xDomPoint(N);
			/// </OLStats Hack>

			// for backwards compatibility with existing cDOM maps
			if ( N.IsA('ClassicDomPoint') )
				bObsoleteCP = True;
			// for compatibility with existing DDOM maps
			if (N.IsA('xDomPointA') || N.IsA('xDomPointB') )
			{
				bObsoleteCP = True;
				N.bObsolete = True;
			}
			i++;
		}
	}

	CPs = CDomPoints.Length;
	if ( CPs == 0 )
		Log("cDOM2: Level ("$UnrealMPGameInfo(Level.Game).GetURLMap(False)$") has NO Control Points!",'Error');

	for (i=0; i < GameReplicationInfo.PRIArray.Length; i++)
		domPRI[i] = cDOM_PlayerReplicationInfo(GameReplicationInfo.PRIArray[i]);
}

state MatchInProgress
{
	/// <summary>
	/// Logic to handle scoring of cDOM2.cDOM_DomPoint type Control Points.
	/// </summary>
	/// <param name="i">The index of the current CDomPoints[i]</param>
	/// <param name="c">The current scoring points value</param>
	function ScoreTeam(int i, float c)
	{
		local int t;

		if ( CDomPoints[i].ControllingTeam != None && CDomPoints[i].bControllable )
		{
			CDomPoints[i].ControllingTeam.Score += c;
			CDomPoints[i].ControllingTeam.NetUpdateTime = Level.TimeSeconds - 1;
			t = CDomPoints[i].ControllingTeam.TeamIndex;
			Pts[t] += c;
			if (Pts[t] >= 1.00000) // Once the score hits 1.0, then log it.
			{
				if ( bExtraStatsLogging )
					TeamScoreEvent(t, Pts[t], "dom_teamscore");
				else
					TeamScoreEvent(t, 1, "dom_teamscore");

				Pts[t] = 0.00000;
			}
			// Update the Timers
			cDOM_DomPoint(CDomPoints[i]).HolderTimer += c;
			cDOM_DomPoint(CDomPoints[i]).TotalHeldTime[t] += c;
			if ( (CDomPoints[i].ControllingPawn != None) && (CDomPoints[i].ControllingPawn.Controller != None) )
			{
				CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo.Score += c;
				CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
				cDOM_PlayerReplicationInfo(CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).StatScore += c;
				if ( cDOM_PlayerReplicationInfo(CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).StatScore >= 1.0000 )
				{
					if ( bExtraStatsLogging )
						ScoreEvent(CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo, cDOM_PlayerReplicationInfo(CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).StatScore, "dom_score");
					else
						ScoreEvent(CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo, 1, "dom_score");

					cDOM_PlayerReplicationInfo(CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).StatScore = 0.0;
				}

				if ( bAwardAdrenaline )
				{
					cDOM_PlayerReplicationInfo(CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).AdrenalineCounter  += c;
					if (cDOM_PlayerReplicationInfo(CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).AdrenalineCounter >= 1.00000)
					{
						CDomPoints[i].ControllingPawn.Controller.AwardAdrenaline(ADR_Goal);
						cDOM_PlayerReplicationInfo(CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).AdrenalineCounter = 0.0;
					}
				}
			}
		}
	}

	/// <summary>
	/// Logic to handle scoring of ClassicDom.ClassicDomPoint type Control Points.
	/// </summary>
	/// <param name="i">The index of the current CDomPoints[i]</param>
	/// <param name="c">The current scoring points value</param>
	function ClassicScoreTeam(int i, float c)
	{
		local int t;

		if ( CDomPoints[i].ControllingTeam != None && CDomPoints[i].bControllable )
		{
			CDomPoints[i].ControllingTeam.Score += c;
			CDomPoints[i].ControllingTeam.NetUpdateTime = Level.TimeSeconds - 1;
			t = CDomPoints[i].ControllingTeam.TeamIndex;
			Pts[t] += c;
			if (Pts[t] >= 1.00000) // Once the score hits 1.0, then log it.
			{
				if ( bExtraStatsLogging )
					TeamScoreEvent(t, Pts[t], "dom_teamscore");
				else
					TeamScoreEvent(t, 1, "dom_teamscore");

				Pts[t] = 0.00000;
			}

			if (CDomPoints[i].bObsolete && (xDomPoints[i] != None))
			{
				if ( (xDomPoints[i].ControllingPawn != None) && (xDomPoints[i].ControllingPawn.Controller != None) )
				{
					xDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo.Score += c;
					xDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
					cDOM_PlayerReplicationInfo(xDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).StatScore += c;
					if ( cDOM_PlayerReplicationInfo(xDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).StatScore >= 1.0000 )
					{
						if ( bExtraStatsLogging )
							ScoreEvent(xDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo, cDOM_PlayerReplicationInfo(xDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).StatScore, "dom_score");
						else
							ScoreEvent(xDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo, 1, "dom_score");

						cDOM_PlayerReplicationInfo(xDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).StatScore = 0.0;
					}

					if ( bAwardAdrenaline )
					{
						cDOM_PlayerReplicationInfo(xDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).AdrenalineCounter  += c;
						if (cDOM_PlayerReplicationInfo(xDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).AdrenalineCounter >= 1.00000)
						{
							xDomPoints[i].ControllingPawn.Controller.AwardAdrenaline(ADR_Goal);
							cDOM_PlayerReplicationInfo(xDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).AdrenalineCounter = 0.0;
						}
					}
				}

			}
			else
			{
				if ( (CDomPoints[i].ControllingPawn != None) && (CDomPoints[i].ControllingPawn.Controller != None) )
				{
					CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo.Score += c;
					CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
					cDOM_PlayerReplicationInfo(CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).StatScore += c;
					if ( cDOM_PlayerReplicationInfo(CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).StatScore >= 1.0000 )
					{
						if ( bExtraStatsLogging )
							ScoreEvent(CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo, cDOM_PlayerReplicationInfo(CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).StatScore, "dom_score");
						else
							ScoreEvent(CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo, 1, "dom_score");

						cDOM_PlayerReplicationInfo(CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).StatScore = 0.0;
					}

					if ( bAwardAdrenaline )
					{
						cDOM_PlayerReplicationInfo(CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).AdrenalineCounter  += c;
						if (cDOM_PlayerReplicationInfo(CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).AdrenalineCounter >= 1.00000)
						{
							CDomPoints[i].ControllingPawn.Controller.AwardAdrenaline(ADR_Goal);
							cDOM_PlayerReplicationInfo(CDomPoints[i].ControllingPawn.Controller.PlayerReplicationInfo).AdrenalineCounter = 0.0;
						}
					}
				}
			}

		}
	}

	function Timer()
	{
		local int i;
		local float c;

		Super(TeamGame).Timer();
		if ( !bGameEnded )
		{
			c = 0.2;
			if (TimeLimit > 0)
			{
				if (RemainingTime < 0.25 * TimeLimit)
				{
					if (RemainingTime < 0.1 * TimeLimit)
						c = 0.8;
					else
						c = 0.4;
				}
			}

			if ( !bPlayersMustBeReady || CountDown <= 0 )
			{
				for (i=0; i < CPs; i++)
				{
					if ( bObsoleteCP )
						ClassicScoreTeam(i, c);
					else
						ScoreTeam(i, c);
				}

				if (GoalScore > 0)
					for (i=0; i < 2; i++)
						if (Teams[i].Score >= GoalScore)
							EndGame(None, "teamscorelimit");
			}
		}
	}
}

function ShowPathTo(PlayerController P, int TeamNum)
{
	local int x;
	local xDomPoint Best;
	local float BestDist;
	local class<WillowWhisp>    WWclass;

	BestDist = 900000;
	for (x = 0; x < CDomPoints.Length; x++)
	{
		if ( (CDomPoints[x].ControllingTeam.TeamIndex == TeamNum) && ((Best == None) || (VSize(P.Pawn.Location - CDomPoints[x].Location) < BestDist)) )
		{
			Best = CDomPoints[x];
			BestDist = VSize(P.Pawn.Location - CDomPoints[x].Location);
		}
	}

	if ( (Best != None) && (P.FindPathToward(Best, False) != None) )
	{
		WWclass = class<WillowWhisp>(DynamicLoadObject(PathWhisps[TeamNum], class'Class'));
		Spawn(WWclass, P,, P.Pawn.Location);
	}
}

function ClearControl(Controller Other)
{
	local Controller P;
	local PlayerController Player;
	local Pawn Pick;
	local int i, x;

	if ( (PlayerController(Other) == None) || (Other.PlayerReplicationInfo.Team.TeamIndex == 255) )
		return;

	for (i=0; i<CPs; i++)
		if (CDomPoints[i].ControllingPawn != Other)
			x++;

	if ( x == CPs )
		return;

	for (P=Level.ControllerList; P!=None; P=P.nextController)
	{
		Player = PlayerController(P);
		if ( (Player != None) && (Player != Other) && (Player.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) )
		{
			Pick = Player.Pawn;
			break;
		}
	}

	for (i=0; i<CPs; i++)
	{
		if (CDomPoints[i].ControllingPawn == Other)
		{
			CDomPoints[i].ControllingPawn = Pick;
			CDomPoints[i].UpdateStatus();
		}
	}
}

function ResetCount() {}

function bool CriticalPlayer(Controller Other)
{
	local int i;

	for (i=0; i<CPs; i++)
	{
		if (CDomPoints[i] != None)
		{
			if ( (Other.Pawn == CDomPoints[i].ControllingPawn) || (vsize(Other.Pawn.Location - CDomPoints[i].Location ) <=1024) )
				return True;
		}
	}

	return Super(TeamGame).CriticalPlayer(Other);
}

function actor FindSpecGoalFor(PlayerReplicationInfo PRI, int TeamIndex)
{
	local XPlayer PC;
	local xDomPoint DP;

	PC = XPlayer(PRI.Owner);
	if (PC==None)
		return none;

	return PC.FindPathTowardNearest(Class'xDomPoint');

	foreach AllActors(Class'xDomPoint',DP)
		return DP;
}

function Logout(Controller Exiting)
{
	ClearControl(Exiting);
	Super(TeamGame).Logout(Exiting);
}

function EndGame(PlayerReplicationInfo Winner, string Reason )
{
	local Controller P;

	if ( Teams[1].Score > Teams[0].Score )
		GameReplicationInfo.Winner = Teams[1];
	else
		GameReplicationInfo.Winner = Teams[0];

	if ( Winner == None )
	{
		for ( P=Level.ControllerList; P!=None; P=P.nextController )
		{
			if ( (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == GameReplicationInfo.Winner)
				&& ((Winner == None) || (P.PlayerReplicationInfo.Score > Winner.Score)) )
			{
				Winner = P.PlayerReplicationInfo;
			}
		}
	}

	EndTime = Level.TimeSeconds + EndTimeDelay;
	SetEndGameFocus(Winner);
	Super.EndGame(Winner,Reason);
}

function SetEndGameFocus(PlayerReplicationInfo Winner)
{
	local Controller P;
	local PlayerController player;
	local int i;
	local float BestCPTime;
	local xDomPoint BestCP;

	if ( Winner != None )
	{
		for (i=0; i<CPs; i++)
		{
			if ( bObsoleteCP && (CDomPoints[i].ControllingTeam.TeamIndex == Winner.Team.TeamIndex) )
			{
				BestCP = CDomPoints[i];
				break;
			}
			else if ( !bObsoleteCP && (CDomPoints[i].ControllingTeam.TeamIndex == Winner.Team.TeamIndex) && (BestCP == None || (BestCPTime < cDOM_DomPoint(CDomPoints[i]).TotalHeldTime[Winner.Team.TeamIndex])) )
			{
				BestCPTime = cDOM_DomPoint(CDomPoints[i]).TotalHeldTime[Winner.Team.TeamIndex];
				BestCP = CDomPoints[i];
			}
		}
	}

	if (BestCP != None)
		EndGameFocus = BestCP;
	else // Randomly pick a Control Point just so we can get on with things
	{
		foreach AllActors(Class'xDomPoint',BestCP)
			if (BestCP.ControllingTeam.TeamIndex == Winner.Team.TeamIndex)
			{
				EndGameFocus = BestCP;
				if (bDebugMode) warn("cDOM2: EndGameFocus is None, Randomly selecting: ["$i$"] "$BestCP.PointName$".");
				break;
			}
	}

	if ( EndGameFocus != None )
		EndGameFocus.bAlwaysRelevant = True;

	for ( P=Level.ControllerList; P!=None; P=P.nextController )
	{
		player = PlayerController(P);
		if ( Player != None )
		{
			if ( !Player.PlayerReplicationInfo.bOnlySpectator )
			PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == GameReplicationInfo.Winner));
			player.ClientSetBehindView(True);
			Player.CameraDist = 10;
			if ( EndGameFocus != None )
			{
				Player.ClientSetViewTarget(EndGameFocus);
				Player.SetViewTarget(EndGameFocus);
			}

			player.ClientGameEnded();
			if ( CurrentGameProfile != None )
				CurrentGameProfile.bWonMatch = (Player.PlayerReplicationInfo.Team == GameReplicationInfo.Winner);
		}
		P.GameHasEnded();
	}
}

static function array<string> GetAllLoadHints(optional bool bThisClassOnly)
{
	local int i;
	local array<string> Hints;

	if ( !bThisClassOnly || default.CDomHints.Length == 0 )
		Hints = Super(TeamGame).GetAllLoadHints();
	for (i = 0; i < default.CDomHints.Length; i++)
		Hints[Hints.Length] = Default.CDomHints[i];

	return Hints;
}

function GetServerDetails(out ServerResponseLine ServerState)
{
	Super(TeamGame).GetServerDetails(ServerState);
	AddServerDetail(ServerState, "Game Type", GameName);
	AddServerDetail(ServerState, "Game Version", CDOMVer);
	AddServerDetail(ServerState, "Unlimited Translocator", bUnlimitedTranslocator);
	AddServerDetail(ServerState, "Award Adrenaline", bAwardAdrenaline);
}

static function FillPlayInfo(PlayInfo PI)
{
	local int i;

	Super(TeamGame).FillPlayInfo(PI);
	PI.AddSetting(default.GameGroup, "bUnlimitedTranslocator", default.CDomPropsDisplayText[i++], 0, 1, "Check",,,,True);
	PI.AddSetting(Default.GameGroup, "bAwardAdrenaline", Default.CDomPropsDisplayText[i++], 0, 1, "Check",,,,True);
}

defaultproperties
{
	CDOMVer="2.0.9"
	bUnlimitedTranslocator=True
	bAwardAdrenaline=True
	bClassicTeamSymbols=True
	bAdvertiseDDOM=True
	bAddCDOM2ServerName=True
	ClassicTeamSymbols(0)="CDOMGameTextures.textures.RedTeamSymbol"
	ClassicTeamSymbols(1)="CDOMGameTextures.textures.BlueTeamSymbol"
	ClassicTeamSymbols(2)="CDOMGameTextures.textures.NeutralSymbol"
	Message4Class=Class'cDOM2.cDOM4_Message'
	CDomHints(0)="Capture and hold Control Points to win."
	CDomHints(1)="Your personal score is a combination of your frags and Control Point captures."
	CDomHints(2)="Your team gets one point, after every five seconds per each Control Point that is your teams color."
	CDomHints(3)="Firing the translocator sends out your translocator beacon.  Pressing %FIRE% again returns the beacon, while pressing %A:TFIRE% teleports you instantly to the beacon's location (if you fit)."
	CDomHints(4)="Pressing %SWITCHWEAPON 10% after tossing the Translocator allows you to view from its internal camera."
	CDomHints(5)="Pressing %FIRE% while your %ALTFIRE% is still held down after teleporting with the translocator will switch you back to your previous weapon."
	CDomHints(6)="You can use %BASEPATH 0% for help finding the path to the nearest Control Point, controlled by the red team.  %BASEPATH 1% will do the same, yet for the blue team."
	CDomHints(7)="Classic Domination internet servers are now listed under the Double Domination servers, and have the prefix '[cDOM]' to the servers name."
	CDomHints(8)="Classic Domination 2 is compatible with the existing cDOM and DOM (Double Dom) maps."
	CDomHints(9)="The new Classic Domination 2 maps adds a new stat, Control Point Captures, to each players ingame stats page.  Press %SHOWSTATS% to see yours or to see another players."
	CDomPropsDisplayText(0)="Unlimited Translocator"
	CDomPropsDisplayText(1)="Award Adrenaline"
	CDomPropDescText(0)="Enable to remove the limited use of the Translocator."
	CDomPropDescText(1)="Award the player with one adrenaline for each, one point they earn their team."
	bSpawnInTeamArea=False
	TeamAIType(0)=Class'cDOM2.cDOM_TeamAI'
	TeamAIType(1)=Class'cDOM2.cDOM_TeamAI'
	ADR_Goal=1.000000
	bAllowTrans=True
	bDefaultTranslocator=True
	LocalStatsScreenClass=Class'cDOM2.cDOM_StatsScreen'
	HUDType="cDOM2.HudCDomination"
	MapListType="cDOM2.MapListCDOM2Game"
	MapPrefix="cDOM"
	BeaconName="cDOM2"
	GoalScore=150
	TimeLimit=0
	OtherMesgGroup="ClassicDomination2"
	MutatorClass="cDOM2.cDOM2GameMut"
	PlayerControllerClassName="cDOM2.cDOM_PlayerController"
	GameName="Classic Domination 2"
	Description="The two teams fight for possession of several control points scattered throughout the map.  To capture a control point, simply touch it.  When a team owns a control point, their score increases steadily until another team touches the control point."
	ScreenShotName="CDOM-Thumbnail2.Shaders.cDOM2Preview"
	DecoTextName="cDOM2.cDOM2Game"
	Acronym="cDOM2"
	MessageClass=Class'cDOM2.cDOM_Message'
}

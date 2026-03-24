//==============================================================================
// abstract Control Point Class - Place actors that are subclasses of this class
// in the map for each control point, on cDOM Maps.
//==============================================================================
Class cDOM_DomPoint extends xDomPoint
	config;

var  Decoration  DomMesh;
var transient float HolderTimer;      // Length of time (in points) this control point has been held without changing hands (Mainly for BotAI)
var transient float TotalHeldTime[4]; // The total ammount of points, this control point has been held, per team..
var           byte  ScoreTime;        // The time after one team touches a control point, til the next team can capture it.
var class<Decoration> DomMeshClass;   // type of Control Point Actor to spawn that will be the rotating Control Point mesh.
var(cDOM_DomPoint) config string DomMeshClassName; // The Class name of the 'DomMeshClass'
var(cDOM_DomPoint) bool          bUseDomRing;      // Spawn the xDomRing.
var(cDOM_DomPoint) bool          bHiddenDomBase;   // Do not actualy show this actor in play. (If true, the lightCone will not be show either)
var(cDOM_DomPoint) config StaticMesh HiddenDomBaseMesh; // Special transparent mesh that has no polygons. for use with bHiddenDomBase.
var(cDOM_DomPoint) config Material DomMeshShader[5];    // Override the Default ControlPointMesh Skins with custom materials.

/// <summary>
/// Validates the input number is a valid 4 Team TeamIndex.
/// </summary>
/// <param name="TeamIndex" type="byte">The TeamIndex 0-255</param>
/// <returns>
/// 0-3 = TeamIndex
/// 4 = Disabled/No Team
/// </returns>
function byte ValidateTeamIndex(byte TeamIndex)
{
	if (TeamIndex > 3)
		return 4;
	else
		return TeamIndex;
}

simulated function PostBeginPlay()
{
	Super(DominationPoint).PostBeginPlay();
	if (Level.NetMode != NM_Client)
	{
		if ( !bUseDomRing )
			DomRing = None;
		else
			DomRing = Spawn(Class'XGame.xDomRing',self,,Location+EffectOffset,Rotation);

		if ( bHiddenDomBase )
			SetStaticMesh(HiddenDomBaseMesh);

		ChangeShader(255);
//      bHidden = True;
	}
}

simulated function PostNetReceive()
{
	local cDOM_Monitor M;
	local byte NewTeam;

	//Super.PostNetReceive();
	NewTeam = 4;
	if ( (ControllingTeam != None) && (ControllingTeam.TeamIndex < 4) )
		NewTeam = ControllingTeam.TeamIndex;

	// send the event to trigger related actors
	ForEach DynamicActors(class'cDOM_Monitor', M, ControlEvent)
	{
		M.NewTeam = NewTeam;
		M.UpdateForTeam();
	}
}

function UpdateStatus()
{
	local Actor A;
	local TeamInfo NewTeam;
	local int OldIndex, i;

	if ( bControllable && ((ControllingPawn == None) || !ControllingPawn.IsPlayerPawn()) )
	{
		ControllingPawn = None;

		// check if any pawn currently touching
		ForEach TouchingActors(class'Pawn', ControllingPawn)
		{
			if ( ControllingPawn.IsPlayerPawn() )
				break;
			else
				ControllingPawn = None;
		}
	}

	// nothing to do if there is already a controlling team but no controlling pawn
	if (ControllingTeam != None && ControllingPawn == None)
		return;

	/// who is the current controlling team of this domination point?
	if (ControllingPawn == None)
		NewTeam = None;
	else
		NewTeam = ControllingPawn.Controller.PlayerReplicationInfo.Team;

	// do nothing if there is no change in the controlling team (and there is a controlling team)
	if ( (NewTeam == ControllingTeam) && (NewTeam != None) )
		return;

	// for AI, update DefenderTeamIndex
	NetUpdateTime = Level.TimeSeconds - 1;
	OldIndex = DefenderTeamIndex;
	if (NewTeam == None)
		DefenderTeamIndex = 255; // ie. "no team" since 0 is a valid team
	else
		DefenderTeamIndex = NewTeam.TeamIndex;

	if (bControllable && (OldIndex != DefenderTeamIndex))
		UnrealMPGameInfo(Level.Game).FindNewObjectives(Self);

	// otherwise we have a new controlling team, or the point is being re-enabled
	ControllingTeam = NewTeam;

	if (ControllingTeam != None)
	{
		PlaySound(ControlSound, SLOT_None, 1.0,,128.0);
		//PlaySound(ControlSound, SLOT_None, 0.8,);
		HolderTimer = 0.00; // Reset the timer
		if ( Level.Game.IsA('cDOM4Game') )
			BroadcastLocalizedMessage(Class'cDOM2Game'.default.Message4Class,ControllingTeam.TeamIndex,None,None,Self);
		else
		{
			BroadcastLocalizedMessage(Class'cDOM2Game'.default.MessageClass,ControllingTeam.TeamIndex,None,None,Self);
			cDOM_PlayerReplicationInfo(ControllingPawn.PlayerReplicationInfo).DomPointCapture += 1;
			if ( Class'cDOM2Game'.Default.bExtraStatsLogging )
			{
				for (i=0; i < Class'cDOM2Game'.default.CPs; i++)
					if ( Class'cDOM2Game'.default.CDomPoints[i] == self )
						UnrealMPGameInfo(Level.Game).GameEvent("dom_point_capture", string(i), ControllingPawn.PlayerReplicationInfo);
			}
		}
	}

	if (ControllingTeam == None)
	{
		if ( !bControllable )
		{
			LightType = LT_None;
			if (DomMesh != None)
				DomMesh.bHidden = True;
		}
		else if ( bControllable )
			ChangeShader(255);
	}
	else
	{
		ScoreTime = 1;
		SetTimer(1.0, True);
		ChangeShader(ControllingTeam.TeamIndex);
	}
	// send the event to trigger related actors
	foreach DynamicActors(class'Actor', A, ControlEvent)
		A.Trigger(Self, ControllingPawn);
}

/// <summary>
/// Dynamicly changes the lighting, hides the DomBase, and/or sets the xDomRing Shader
/// </summary>
/// <param name="CPTeam">The ControllingTeam</param>
simulated function ChangeShader(byte CPTeam)
{
	local byte Hue, Saturat;
	local float Brt;

	CPTeam = ValidateTeamIndex(CPTeam);
	Brt = 255.0;
	Saturat = 0;
	if (CPTeam == 0)
		Hue = 255;
	else if (CPTeam == 1)
		Hue = 170;
	else if (CPTeam == 2)
		Hue = 85;
	else if (CPTeam == 3)
		Hue = 33;
	else
	{
		Brt = 92;
		Hue = 35;
		Saturat = 166;
	}
	LightBrightness = Brt;
	LightHue = Hue;
	LightSaturation = Saturat;

	if ( bHiddenDomBase )
		if (StaticMesh != HiddenDomBaseMesh)
			SetStaticMesh(HiddenDomBaseMesh);

	if (DomRing != None)
	{
		DomRing.bHidden = False;
		if ( DomMeshShader[CPTeam] != None )
		{
			DomRing.Skins[0] = DomMeshShader[CPTeam];
			DomRing.RepSkin = DomMeshShader[CPTeam];
		}
		else
		{
			if (CPTeam == 0)
			{
				DomRing.Skins[0] = Class'xDomRing'.Default.RedTeamShader;
				DomRing.RepSkin = Class'xDomRing'.Default.RedTeamShader;
			}
			else if (CPTeam == 1)
			{
				DomRing.Skins[0] = Class'xDomRing'.Default.BlueTeamShader;
				DomRing.RepSkin = Class'xDomRing'.Default.BlueTeamShader;
			}
			else if (CPTeam == 2)
			{
				DomRing.Skins[0] = Shader'CDOMGameTextures.Shaders.DOMGreenS';
				DomRing.RepSkin = Shader'CDOMGameTextures.Shaders.DOMGreenS';
			}
			else if (CPTeam == 3)
			{
				DomRing.Skins[0] = Shader'CDOMGameTextures.Shaders.DOMGoldS';
				DomRing.RepSkin = Shader'CDOMGameTextures.Shaders.DOMGoldS';
			}
			else
			{
				DomRing.Skins[0] = Class'xDomRing'.Default.NeutralShader;
				DomRing.RepSkin = Class'xDomRing'.Default.NeutralShader;
			}
		}
	}
}

simulated function Tick( float t )
{
	Super(DominationPoint).Tick(t);
}

function ResetPoint(bool enabled)
{
	local Controller P;

	Super.ResetPoint(enabled);
	if ( !Level.Game.bGameEnded )
	{
		for( P=Level.ControllerList; P!=None; P=P.nextController )
			if ( (P.PlayerReplicationInfo != None) && (cDOM_PlayerReplicationInfo(P.PlayerReplicationInfo) != None) && (cDOM_PlayerReplicationInfo(P.PlayerReplicationInfo).DomPointCapture > 0) )
				cDOM_PlayerReplicationInfo(P.PlayerReplicationInfo).DomPointCapture = 0;
	}
}

/// <summary>
/// Don't call Super here since we don't want it incrementing score!
/// </summary>
function Timer()
{
	ScoreTime--;
	if (ScoreTime > 0)
		bControllable = False;
	else
	{
		ScoreTime = 0;
		bControllable = True;
		SetTimer(0.00000, False);
	}
}

function bool BetterObjectiveThan(GameObjective Best, byte DesiredTeamNum, byte RequesterTeamNum)
{
	if ( !IsActive() || (DefenderTeamIndex != DesiredTeamNum) )
		return False;
	if ( (Best == None) || (Best.DefensePriority < DefensePriority) || (DefenderTeamIndex == DesiredTeamNum) )
		return True;
	return False;
}

defaultproperties
{
	HiddenDomBaseMesh=StaticMesh'CDOM-GameMeshes.DOMpoint.BaseHidden'
	PointName="Position"
	ControlSound=Sound'CDOM-Sounds.Domination.ControlSound'
	EffectOffset=(Z=24.000000)
	PrimaryTeam=255
	ObjectiveName="Control Point x"
	LightHue=35
	LightSaturation=166
	LightBrightness=255.000000
	LightRadius=8.000000
	StaticMesh=StaticMesh'CDOM-GameMeshes.DOMpoint.Base'
	PrePivot=(Z=84.000000)
	CollisionHeight=48.000000
	bEdShouldSnap=True
}

//=============================================================================
// Classic Domination Control Point (With 4 Team Support)
//=============================================================================
// Making CDOM maps- In UnrealEditor, place this actor in the map and for each
// control point; give each a unique name for these two properties:
// 1) xDomPoint.PointName - The control points name.
// 2) GameObjective.ObjectiveName - I think this is for Bot AI.
//=============================================================================
// Using "bControllable" as "bScoreReady" was used in UT99
//=============================================================================
class ClassicDomPoint extends xDomPoint
	placeable;

var transient bool bClassicControlPoint; // This is must be set in the PreBeginPlay of the calling Game
var byte ScoreTime; // The time after one team touches a control point, til the next team can capture it.
var int  HolderID;  // PlayerID of the ControllingPawn for replication
var ClassicDomLetter    CDomLetter;
var ClassicDomRing      CDomRing;
var ClassicControlPoint CDomCCP;
var() material NeutralShader, RedTeamShader, BlueTeamShader, GreenTeamShader, GoldTeamShader; // Cache the Shaders

replication
{
	reliable if (Role == ROLE_Authority)
		HolderID;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (Level.NetMode != NM_Client)
	{
		if (bClassicControlPoint)
		{
			NeutralShader = class'ClassicControlPoint'.default.NeutralShader;
			RedTeamShader = class'ClassicControlPoint'.default.RedTeamShader;
			BlueTeamShader = class'ClassicControlPoint'.default.BlueTeamShader;
			GreenTeamShader = class'ClassicControlPoint'.default.GreenTeamShader;
			GoldTeamShader = class'ClassicControlPoint'.default.GoldTeamShader;
			CDomCCP = Spawn(class'ClassicDom.ClassicControlPoint',self,,Location+EffectOffset,Rotation);
		}
		else
		{
			NeutralShader = class'ClassicDomLetter'.default.NeutralShader;
			RedTeamShader = class'ClassicDomLetter'.default.RedTeamShader;
			BlueTeamShader = class'ClassicDomLetter'.default.BlueTeamShader;
			GreenTeamShader = class'ClassicDomLetter'.default.GreenTeamShader;
			GoldTeamShader = class'ClassicDomLetter'.default.GoldTeamShader;
			CDomLetter = Spawn(class'ClassicDom.ClassicDomLetter',self,,Location+EffectOffset,Rotation);
			CDomRing = Spawn(class'ClassicDom.ClassicDomRing',self,,Location+EffectOffset,Rotation);
		}
		bHidden = True;
		ChangeShader(255); // Neutral shader
		Skins[1] = none;
	}
}

// We use PlayerID to track each pawns score. This way player will receive credit for the
// control point they captured even after death. Like in UT99.
function SetHolder(Controller C)
{
	HolderID = C.PlayerReplicationInfo.PlayerID;
}

// Touching pawn = the controlling pawn for this point.
function Touch(Actor Other)
{
	if ( (Pawn(Other) == None) || !Pawn(Other).IsPlayerPawn() )
		return;

	if (bControllable && (ControllingTeam != Pawn(Other).PlayerReplicationInfo.Team))
	{
		ControllingPawn = Pawn(Other);
		SetHolder(Pawn(Other).Controller);
		UpdateStatus();
	}
}

// Fixed an issue with the players gun muzzle flashing when they did not fire their weapon. We will not use
// the 'foreach DynamicActors' (event to trigger related actors at the end of the function) to fix this.
function UpdateStatus()
{
	local TeamInfo NewTeam;
	local int OldIndex;

	if ( bControllable && ( (ControllingPawn == None) || !ControllingPawn.IsPlayerPawn()) )
	{
		ControllingPawn = None;
		// check if any pawn currently touching
		foreach TouchingActors(class'Pawn', ControllingPawn)
		{
			if (ControllingPawn.IsPlayerPawn())
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
		UnrealMPGameInfo(Level.Game).FindNewObjectives(self);

	// otherwise we have a new controlling team, or the point is being re-enabled
	ControllingTeam = NewTeam;
	if (ControllingTeam != None)
	{
		BroadcastLocalizedMessage(MessageClass,ControllingTeam.TeamIndex,None,None,self);
		UnrealMPGameInfo(Level.Game).GameEvent("dom_point_capture", string(ControllingTeam.TeamIndex), ControllingPawn.Controller.PlayerReplicationInfo);
		PlaySound(ControlSound,SLOT_None,0.9);
	}

	if (ControllingTeam == none)
	{
		if ( !bControllable )
		{
			LightType = LT_None;
			if (CDomLetter != None)
				CDomLetter.bHidden = True;
			if (CDomRing != None)
				CDomRing.bHidden = True;
			if (CDomCCP != None)
				CDomCCP.bHidden = True;
		}
		else if (bControllable)
			ChangeShader(255); // set to neutral
	}
	else
	{
		ScoreTime = 1;
		SetTimer(1.0, True);
		ChangeShader(ControllingPawn.Controller.PlayerReplicationInfo.Team.TeamIndex);
	}
}

// Dynamically change at runtime, the Control Point shaders and even maybe the StaticMesh.
// <param name="CPTeam">TeamID of team that made the control point capture</param>
simulated function ChangeShader(byte CPTeam)
{
	local byte Brt, Hue, Saturat;
	local Material mat1;

	if (CPTeam == 0)
	{
		Brt = 150;
		Hue = 0;
		Saturat = 0;
		mat1 = RedTeamShader;
	}
	else if (CPTeam == 1)
	{
		Brt = 150;
		Hue = 177;
		Saturat = 0;
		mat1 = BlueTeamShader;
	}
	else if (CPTeam == 2)
	{
		Brt = 150;
		Hue = 85;
		Saturat = 0;
		mat1 = GreenTeamShader;
	}
	else if (CPTeam == 3)
	{
		Brt = 120;
		Hue = 42;
		Saturat = 64;
		mat1 = GoldTeamShader;
	}
	else // No Team (Neutral)
	{
		Brt = 92;
		Hue = 35;
		Saturat = 166;
		mat1 = NeutralShader;
		Super.SetShaderStatus(CNeutralState[0],SNeutralState,CNeutralState[1]);
	}

	LightBrightness = Brt;
	LightHue = Hue;
	LightSaturation = Saturat;
	if (CDomLetter != None)
	{
		CDomLetter.bHidden = False;
		CDomLetter.Skins[0] = mat1;
		CDomLetter.RepSkin = mat1;
		CDomLetter.LightBrightness = Brt;
		CDomLetter.LightHue = Hue;
		CDomLetter.LightSaturation = Saturat;
	}

	if (CDomRing != none)
	{
		CDomRing.bHidden = False;
		CDomRing.Skins[0] = mat1;
		CDomRing.RepSkin = mat1;
		CDomRing.LightBrightness = Brt;
		CDomRing.LightHue = Hue;
		CDomRing.LightSaturation = Saturat;
	}

	if (CDomCCP != none)
	{
		CDomCCP.bHidden = False;
		CDomCCP.Skins[0] = mat1;
		CDomCCP.RepSkin = mat1;
		CDomCCP.LightBrightness = Brt;
		CDomCCP.LightHue = Hue;
		CDomCCP.LightSaturation = Saturat;
		// Dynamically change the StaticMesh
		if (CPTeam == 0)
			CDomCCP.SetStaticMesh(StaticMesh'CDOM-GameMeshes.ControlPoint.DomRed');
		else if (CPTeam == 1)
			CDomCCP.SetStaticMesh(StaticMesh'CDOM-GameMeshes.ControlPoint.DomBlue');
		else if (CPTeam == 2)
			CDomCCP.SetStaticMesh(StaticMesh'CDOM-GameMeshes.ControlPoint.DomGreen');
		else if (CPTeam == 3)
			CDomCCP.SetStaticMesh(StaticMesh'CDOM-GameMeshes.ControlPoint.DomGold');
		else // No Team (Neutral)
			CDomCCP.SetStaticMesh(StaticMesh'CDOM-GameMeshes.ControlPoint.DomNeutral');

		CDomCCP.bLightChanged = True;
	}
}

simulated function Tick( float t ) {}

// Don't call super here since we don't want it incrementing score!
function Timer()
{
	ScoreTime--;
	if (ScoreTime > 0)
		bControllable = False;
	else
	{
		ScoreTime = 0;
		bControllable = True;
		SetTimer(0.0, False);
	}
}

function ResetPoint(bool enabled)
{
	if ( !bControllable && enabled )
		UnrealMPGameInfo(Level.Game).FindNewObjectives(self);

	NetUpdateTime = Level.TimeSeconds - 1;
	bControllable = enabled;
	HolderID = 255;
	ControllingPawn = None;
	ControllingTeam = None;
	UpdateStatus();
}

defaultproperties
{
	PointName="Position"
	ControlSound=Sound'CDOM-Sounds.Domination.ControlSound'
	EffectOffset=(Z=24.000000)
	ObjectiveName="Control Point x"
	LightType=LT_Steady
	LightHue=35
	LightSaturation=166
	LightBrightness=96.000000
	LightRadius=10.000000
	PrePivot=(Z=74.000000)
	Skins(1)=None
	CollisionRadius=34.000000
	CollisionHeight=46.000000
	bEdShouldSnap=True
	MessageClass=Class'ClassicDom.ClassicDomMessage'
}

//==============================================================================
// Control Point (With 4 Team Support) v2.5
//==============================================================================
// Making CDOM maps- In UnrealEditor, place this actor in the map and for each
// control point; give each a unique name for these two properties:
// 1) xDomPoint.PointName - The control points name.
// 2) GameObjective.ObjectiveName - For BotAI.
//==============================================================================
// Using "bControllable" as "bScoreReady" was used in UT99
//==============================================================================
class ControlPoint extends cDOM_DomPoint
	placeable
	config;

var LightCone CPLightCone;
var(cDOM_DomPoint) config StaticMesh ControlPointMeshes[5]; // Array of the staticmeshes used for the controlling team.
var(cDOM_DomPoint) bool bLightCone; // Display Light Cone for clients who have the World Detail set greater then Low.

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (Level.NetMode != NM_Client)
	{
		if ( DomMeshClassName != "" )
		{
			DomMeshClass = class<Decoration>(DynamicLoadObject(DomMeshClassName, Class'Class'));
			if ( DomMeshClass != None )
				DomMesh = spawn(DomMeshClass,Self,,Location+EffectOffset,Rotation);
		}
		if ( DomMesh == None )
			DomMesh = Spawn(Class'cDOM2.ControlPointMesh',Self,,Location+EffectOffset,Rotation);
		if ( !bHiddenDomBase && bLightCone )
			ShowLightCone(255);

		ChangeShader(255);
	}
}

/// <summary>
/// Displays the cDOM_DomPoint's LightCone
/// </summary>
/// <param name="TeamSkin">The TeamID</param>
simulated function ShowLightCone(byte TeamSkin)
{
	// Only show as long as it is not the server and the World Detail setting is higher then Low.
	if ( !bHiddenDomBase && (Level.NetMode != NM_DedicatedServer) && (Level.DetailMode != DM_Low) )
	{
		if (CPLightCone == None)
		{
			CPLightCone = Spawn(Class'cDOM2.LightCone',Self,,Location+EffectOffset,Rotation);
			CPLightCone.SetBase(Self);
		}
		if (CPLightCone != None)
		{
			TeamSkin = ValidateTeamIndex(TeamSkin);
			CPLightCone.bHidden = False;
			CPLightCone.Skins[0] = CPLightCone.default.ConeColor[TeamSkin];
			CPLightCone.RepSkin = CPLightCone.default.ConeColor[TeamSkin];
		}
	}
}

/// <summary>
/// Dynamically change at runtime, the Control Point shaders and even maybe the StaticMesh.
/// </summary>
/// <param name="CPTeam" type="byte">TeamID of team that made the control point capture</param>
simulated function ChangeShader(byte CPTeam)
{
	local byte Hue, Saturat;
	local float Brt;

	super.ChangeShader(CPTeam);
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

	if (DomMesh != None)
	{
		DomMesh.bHidden = False;
		DomMesh.SetStaticMesh(ControlPointMeshes[CPTeam]); // Dynamically change the StaticMesh
		DomMesh.LightBrightness = Brt;
		DomMesh.LightHue = Hue;
		DomMesh.LightSaturation = Saturat;
		if ( DomMeshShader[CPTeam] != None )
		{
			DomMesh.Skins[0] = DomMeshShader[CPTeam];
			DomMesh.RepSkin = DomMeshShader[CPTeam];
		}
	}

	if ( bLightCone )
		ShowLightCone(CPTeam);
}

defaultproperties
{
	ControlPointMeshes(0)=StaticMesh'CDOM-GameMeshes.ControlPoint.DomRed'
	ControlPointMeshes(1)=StaticMesh'CDOM-GameMeshes.ControlPoint.DomBlue'
	ControlPointMeshes(2)=StaticMesh'CDOM-GameMeshes.ControlPoint.DomGreen'
	ControlPointMeshes(3)=StaticMesh'CDOM-GameMeshes.ControlPoint.DomGold'
	ControlPointMeshes(4)=StaticMesh'CDOM-GameMeshes.ControlPoint.DomNeutral'
	DomMeshClassName="cDOM2.ControlPointMesh"
}

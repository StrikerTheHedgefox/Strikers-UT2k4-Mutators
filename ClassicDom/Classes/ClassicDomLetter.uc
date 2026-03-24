//=============================================================================
// Dregs Style Control Points
// The config Material allows for user-defined custom shaders.
//=============================================================================
class ClassicDomLetter extends Decoration
	config;

var() config Material  NeutralShader, RedTeamShader, BlueTeamShader, GreenTeamShader, GoldTeamShader;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetLocation(Location + vect(0,0,7.5)); // adjust because reduced drawscale
}

defaultproperties
{
	NeutralShader=TexEnvMap'CDOM-Textures.cdomWhiteFinal'
	RedTeamShader=TexEnvMap'CDOM-Textures.cdomRedFinal'
	BlueTeamShader=TexEnvMap'CDOM-Textures.cdomBlueFinal'
	GreenTeamShader=TexEnvMap'CDOM-Textures.cdomGreenFinal'
	GoldTeamShader=TexEnvMap'CDOM-Textures.cdomGoldFinal'
	LightType=LT_Steady
	LightHue=35
	LightSaturation=166
	LightBrightness=92.000000
	LightRadius=9.000000
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'CDOM-StaticMeshes.ControlPoint.cdom'
	bStatic=False
	bStasis=False
	bAlwaysRelevant=True
	Physics=PHYS_Rotating
	DrawScale=0.190000
	Skins(0)=TexEnvMap'CDOM-Textures.cdomWhiteFinal'
	AmbientGlow=68
	bStaticLighting=True
	bNetNotify=True
	bFixedRotationDir=True
	RotationRate=(Yaw=11000)
}

//=============================================================================
// Classic Style Control Points (UT99 style)
// The config Material allows for user-defined custom shaders.
//=============================================================================
class ClassicControlPoint extends Decoration
	config;
	
#exec OBJ LOAD FILE="CDOM-StaticMeshes.usx"
#exec OBJ LOAD FILE="CDOM-Textures.utx"
#exec OBJ LOAD FILE="CDOM-GameMeshes.usx"
#exec OBJ LOAD FILE="CDOMGameTextures.utx"

var() config Material  NeutralShader, RedTeamShader, BlueTeamShader, GreenTeamShader, GoldTeamShader;

defaultproperties
{
	NeutralShader=Shader'CDOMGameTextures.Shaders.S_Vertex_Neutral'
	RedTeamShader=Shader'CDOMGameTextures.Shaders.S_Vertex_Red'
	BlueTeamShader=Shader'CDOMGameTextures.Shaders.S_Vertex_Blue'
	GreenTeamShader=Shader'CDOMGameTextures.Shaders.S_Vertex_Green'
	GoldTeamShader=Shader'CDOMGameTextures.Shaders.S_Vertex_Gold'
	LightType=LT_Steady
	LightHue=35
	LightSaturation=166
	LightBrightness=92.000000
	LightRadius=9.000000
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'CDOM-GameMeshes.ControlPoint.DomNeutral'
	bStatic=False
	bStasis=False
	bAlwaysRelevant=True
	Physics=PHYS_Rotating
	DrawScale=0.390000
	Skins(0)=Shader'CDOMGameTextures.Shaders.S_Vertex_Neutral'
	AmbientGlow=68
	bStaticLighting=True
	bNetNotify=True
	bFixedRotationDir=True
	RotationRate=(Yaw=5000)
	DesiredRotation=(Yaw=30000)
}

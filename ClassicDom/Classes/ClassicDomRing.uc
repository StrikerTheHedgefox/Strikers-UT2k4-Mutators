class ClassicDomRing extends Decoration;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetLocation(Location + vect(0,0,9.5)); // adjust because reduced drawscale
}

defaultproperties
{
	LightType=LT_Steady
	LightHue=35
	LightSaturation=166
	LightBrightness=92.000000
	LightRadius=9.000000
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'XGame_rc.DomRing'
	bStatic=False
	bStasis=False
	bAlwaysRelevant=True
	Physics=PHYS_Rotating
	DrawScale=0.140000
	Skins(0)=TexEnvMap'CDOM-Textures.cdomWhiteFinal'
	AmbientGlow=64
	bStaticLighting=True
	bNetNotify=True
	bFixedRotationDir=True
	RotationRate=(Yaw=-18000,Roll=48000)
}

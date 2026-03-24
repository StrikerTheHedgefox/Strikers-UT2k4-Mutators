Class LightCone extends Decoration
	config;

var() config Material ConeColor[5]; // The skins to use for the controlling team: 0=Red team, 1=Blue, 2=Green, 3=Gold, 4=Neutral

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial( class'LightCone'.default.ConeColor[0] );
	Level.AddPrecacheMaterial( class'LightCone'.default.ConeColor[1] );
	Level.AddPrecacheMaterial( class'LightCone'.default.ConeColor[2] );
	Level.AddPrecacheMaterial( class'LightCone'.default.ConeColor[3] );
	Level.AddPrecacheMaterial( class'LightCone'.default.ConeColor[4] );
	Super.UpdatePrecacheMaterials();
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(class'LightCone'.default.StaticMesh);
	Super.UpdatePrecacheStaticMeshes();
}

defaultproperties
{
	ConeColor(0)=TexPanner'CDOMGameTextures.Modifiers.LC_PanRed'
	ConeColor(1)=TexPanner'CDOMGameTextures.Modifiers.LC_PanBlue'
	ConeColor(2)=TexPanner'CDOMGameTextures.Modifiers.LC_PanGreen'
	ConeColor(3)=TexPanner'CDOMGameTextures.Modifiers.LC_PanGold'
	ConeColor(4)=TexPanner'CDOMGameTextures.Modifiers.LC_PanNeutral'
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'CDOM-GameMeshes.Deco.LightCone'
	bStatic=False
	bHighDetail=True
	bStasis=False
	bAcceptsProjectors=False
	DrawScale=0.680000
	PrePivot=(Z=14.000000)
	Skins(0)=TexPanner'CDOMGameTextures.Modifiers.LC_PanNeutral'
	bHardAttach=True
	bBlockZeroExtentTraces=False
	bBlockNonZeroExtentTraces=False
}

class HudCDomination extends HudCTeamDeathMatch;

var float tmpPosX, tmpPosY, tmpScaleX, tmpScaleY;
var array<SpriteWidget> PointIcons;
struct EPointInfo
{
	var array<SpriteWidget> PointIcons;
	var xDomPoint thePoint;
};
var protected array<EPointInfo> Points;
var() SpriteWidget ConSymbols[2];
var() SpriteWidget NeutralSymbol;

// From 3374.
function Draw2DLocationDot2(
	Canvas C,
	vector Loc,
	float PosX, float PosY, // [0..1] // screen relative position of the center
	float OffsetX, float OffsetY, // Absolute offset from PosX/Y in units of a virtual 640x480 screen
	float Radius, // Absolute radius on a virtual 640x480 screen
	float DotScale) 
{
	local rotator Dir;
	local float Angle, Scaling;
	local Actor Start;

	if ( PawnOwner == None )
		Start = PlayerOwner;
	else
		Start = PawnOwner;

	Dir = rotator(Loc - Start.Location);
	Angle = ((Dir.Yaw - PlayerOwner.Rotation.Yaw) & 65535) * 6.2831853/65536;
	Scaling = 24*C.ClipX*DotScale/1600;

	C.Style = ERenderStyle.STY_Alpha;
	C.SetPos(
		PosX*C.ClipX + OffsetX*ResScaleX + Radius*ResScaleX*Sin(Angle) - Scaling*0.5,
		PosY*C.ClipY + OffsetY*ResScaleX - Radius*ResScaleY*Cos(Angle) - Scaling*0.5
	);

	C.DrawTile(LocationDot, Scaling, Scaling,340,432,78,78);
}

simulated function PostBeginPlay()
{
	local int h, i;
	local float j;
	local NavigationPoint N;
	local EPointInfo NewPoint;

	i = 0;
	for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		if ( N.IsA('xDomPoint') )
		{
			NewPoint.thePoint = xDomPoint(N);
			Points[i] = NewPoint;
			i++;
		}

	j = 0.75 - (i * 0.05);
	for ( i=0; i<Points.Length; i++ )
	{
		for ( h=0; h<PointIcons.Length; h++ )
		{
			Points[i].PointIcons[h] = PointIcons[h];
			Points[i].PointIcons[h].PosY = j;
		}
		j+=0.073;
	}

	Super.PostBeginPlay();
	SetTimer(1.0, True);
}

simulated function ShowPointBarBottom(Canvas C) {}
simulated function ShowPointBarTop(Canvas C) {}
simulated function ShowPersonalScore(Canvas C) {}
simulated function ShowTeamScorePassA(Canvas C)
{
	local int i;

	Super.ShowTeamScorePassA(C);
	if ( bShowPoints )
		for ( i=0; i<Points.Length; i++ )
		{
			DrawSpriteWidget(C,Points[i].PointIcons[1]);
			DrawSpriteWidget(C,Points[i].PointIcons[2]);
		}
}

simulated function ShowTeamScorePassC(Canvas C)
{
	local int i;
	
	Super.ShowTeamScorePassC(C);
	if ( bShowPoints )
	{
		for ( i=0; i<Points.Length; i++ )
		{
			DrawSpriteWidget(C,Points[i].PointIcons[0]);
			DrawSpriteWidget(C,Points[i].PointIcons[3]);
			if ( Points[i].PointIcons[4].WidgetTexture != None )
				DrawSpriteWidget(C,Points[i].PointIcons[4]);

			C.DrawColor = WhiteColor;
			C.SetPos(C.ClipX+(-99.0*HUDScale*HudCanvasScale*ResScaleX),C.ClipY*(Points[i].PointIcons[0].PosY+0.02*HUDScale));
			C.Font = MyGetSmallFontFor(C);
			if ( len(Points[i].thePoint.PointName) > 0 )
				C.DrawText(Points[i].thePoint.PointName,true);
			else if ( len(Points[i].thePoint.ObjectiveName) > 0 )
				C.DrawText(Points[i].thePoint.ObjectiveName,true);
			else if ( len(Points[i].thePoint.GetHumanReadableName()) > 0 )
				C.DrawText(Points[i].thePoint.GetHumanReadableName(),true);

			C.DrawColor = GoldColor;
			Draw2DLocationDot2(
				C,
				Points[i].ThePoint.Location,
				1.0, Points[i].PointIcons[0].PosY,
				-16.0*HUDScale, 16.0*HUDScale,
				16.0*HUDScale,
				HUDScale
			);
		}
	}
}

simulated function UpdateTeamHud()
{
	local int i,j;

	for ( i=0; i<Points.Length; i++ )
	{
		Points[i].PointIcons[4].OffsetY = 35;
		if ( Points[i].thePoint.ControllingTeam != None )   // Draw Controlling Teams Symbol
		{
			j = Points[i].thePoint.ControllingTeam.TeamIndex;
			Points[i].PointIcons[4].WidgetTexture = TeamSymbols[j].WidgetTexture;
			Points[i].PointIcons[4].TextureCoords = ConSymbols[0].TextureCoords;
			Points[i].PointIcons[4].TextureScale = ConSymbols[0].TextureScale;
			Points[i].PointIcons[4].Tints[0] = ConSymbols[j].Tints[0];
			Points[i].PointIcons[4].Tints[1] = ConSymbols[j].Tints[1];
			Points[i].PointIcons[4].PosX = 0.9961;
		}
		else if (Points[i].thePoint.ControllingTeam == None) // Draw Neutral Symbol
		{
			Points[i].thePoint.ControllingPawn = None;
			Points[i].PointIcons[4].WidgetTexture = NeutralSymbol.WidgetTexture;
			Points[i].PointIcons[4].TextureCoords = NeutralSymbol.TextureCoords;
			Points[i].PointIcons[4].TextureScale = NeutralSymbol.TextureScale;
			Points[i].PointIcons[4].Tints[0] = NeutralSymbol.Tints[0];
			Points[i].PointIcons[4].Tints[1] = NeutralSymbol.Tints[1];
			Points[i].PointIcons[4].PosX = 0.99602;
		}
	}

	Super.UpdateTeamHud();
}

function Font MyGetSmallFontFor(canvas Canvas)
{
	local int i;

	for(i=1; i<8; i++)
	{
		if ( class'HudBase'.default.FontScreenWidthSmall[i] <= Canvas.ClipX )
			return class'HudBase'.static.LoadFontStatic(i+1);
	}
	return class'HudBase'.static.LoadFontStatic(7);
}

defaultproperties
{
	tmpPosX=0.031000
	tmpPosY=0.024000
	tmpScaleX=0.021000
	tmpScaleY=0.030500
	PointIcons(0)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=979,Y1=900,X2=611,Y2=1023),TextureScale=0.230000,DrawPivot=DP_UpperRight,PosX=1.000000,OffsetX=-95,OffsetY=10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
	PointIcons(1)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=979,Y1=777,X2=611,Y2=899),TextureScale=0.230000,DrawPivot=DP_UpperRight,PosX=1.000000,OffsetX=-95,OffsetY=10,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(R=100,A=100),Tints[1]=(B=102,G=66,R=37,A=150))
	PointIcons(2)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=979,Y1=654,X2=611,Y2=776),TextureScale=0.230000,DrawPivot=DP_UpperRight,PosX=1.000000,OffsetX=-95,OffsetY=10,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(R=100,A=80),Tints[1]=(B=120,G=75,R=48,A=80))
	PointIcons(3)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(Y1=880,X2=142,Y2=1023),TextureScale=0.230000,DrawPivot=DP_UpperRight,PosX=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
	PointIcons(4)=(RenderStyle=STY_Alpha,DrawPivot=DP_UpperRight,Scale=0.860000)
	ConSymbols(0)=(RenderStyle=STY_Alpha,TextureCoords=(X2=256,Y2=256),TextureScale=0.102000,DrawPivot=DP_UpperRight,Tints[0]=(B=32,G=32,R=255,A=255),Tints[1]=(B=32,G=32,R=255,A=255))
	ConSymbols(1)=(RenderStyle=STY_Alpha,TextureCoords=(X2=256,Y2=256),TextureScale=0.102000,DrawPivot=DP_UpperRight,Tints[0]=(B=255,G=128,R=64,A=250),Tints[1]=(B=255,G=128,R=64,A=250))
	NeutralSymbol=(WidgetTexture=Texture'CDOMGameTextures.Textures.NeutralSymbol',RenderStyle=STY_Alpha,TextureCoords=(X2=256,Y2=256),TextureScale=0.102000,DrawPivot=DP_UpperRight,Tints[0]=(B=210,G=210,R=210,A=220),Tints[1]=(B=210,G=210,R=210,A=220))
}

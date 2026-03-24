//==============================================================================
// Monitors for use with Classic Domination 2.
// Displays the Control Points name in the upper little monitor,
// and displays the current controlling team in the lower bigger monitor.
// Or if being used for a Camera Monitor, display the scriptedTexture. (See
// cDOM-Lament for an example on how this can be done). The Camera Monitor will
// Default back to being a normal cDOM Monitor when playing online.
//
// To Use: Set the monitors tags to match the ControlPoint's ControlEvent
// (e.g.: ControlPoint.ControlEvent == cDOMMonitorA.tag )
//==============================================================================
Class cDOM_Monitor extends xMonitor
	abstract;

var() Material TeamShader[6];
var   byte     NewTeam;
var ScriptedTexture LicensePlate;   // Borrowed from Onslaught.ONSPRV class
var Material        LicensePlateFallBack;
var Material        LicensePlateBackground;
var string          LicensePlateName;
var Font            LicensePlateFont;
var() bool bCameraMonitor;  // If this monitor is being used as a Camera Monitor, then dont change the skin during play. (CameraMonitorTexture Property will be used if true)
var() ScriptedTexture CameraMonitorTexture;

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(TeamShader[0]);
	Level.AddPrecacheMaterial(TeamShader[1]);
	Level.AddPrecacheMaterial(TeamShader[4]);
	Super(Decoration).UpdatePrecacheMaterials();
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(class'cDOM_Monitor'.default.StaticMesh);
	Super(Decoration).UpdatePrecacheStaticMeshes();
}

simulated function UpdateForTeam()
{
	local byte i;

	if ( bCameraMonitor )
		if (Level.NetMode == NM_Standalone)
			goto OfflineCam;

	goto Online;

	OfflineCam:
		Skins[3] = CameraMonitorTexture;
		goto end;
	Online:
		if (NewTeam > 4)
			i = 4;
		else if ( (NewTeam < 5) && (NewTeam >= 0) )
			i = NewTeam;

		Skins[3] = TeamShader[i];  // Lower big screen
		goto end;
	end:
}

simulated function Trigger( actor Other, pawn EventInstigator )
{
	local xDomPoint DPoint;

	DPoint = xDomPoint(Other);
	if ( DPoint != None )
	{
		if ((DPoint.ControllingTeam != None) && ((DPoint.ControllingTeam.TeamIndex < 4) && (DPoint.ControllingTeam.TeamIndex >= 0)) )
			NewTeam = DPoint.ControllingTeam.TeamIndex;
		else
			NewTeam = 4;

		UpdateForTeam();
	}
}

simulated function PostBeginPlay()
{
	local array<String> Characters;
	local int i, AscCode;
	local xDomPoint CP;

	Super.PostBeginPlay();
	if (Level.NetMode != NM_DedicatedServer)
	{
		LicensePlate = ScriptedTexture(Level.ObjectPool.AllocateObject(class'ScriptedTexture'));
		LicensePlate.SetSize(128,128);
		LicensePlate.FallBackMaterial = LicensePlateFallBack;
		LicensePlate.Client = Self;
		Skins[2] = LicensePlate;	// Small screen
		LicensePlateFont = Font(DynamicLoadObject("2k4Fonts.Verdana22", class'Font'));
	}

	if (LicensePlate != None)
	{
		foreach AllActors(class'xDomPoint', CP)
			if (CP.ControlEvent == self.Tag)
			{
				LicensePlateName = CP.PointName;
				if (Len(LicensePlateName) > 8)
				{
					// First try removing all brackets, braces, greater/less-thans, and parentheses
					LicensePlateName = Repl(LicensePlateName, "[", "", false);
					LicensePlateName = Repl(LicensePlateName, "]", "", false);
					LicensePlateName = Repl(LicensePlateName, "(", "", false);
					LicensePlateName = Repl(LicensePlateName, ")", "", false);
					LicensePlateName = Repl(LicensePlateName, "{", "", false);
					LicensePlateName = Repl(LicensePlateName, "}", "", false);
					LicensePlateName = Repl(LicensePlateName, "<", "", false);
					LicensePlateName = Repl(LicensePlateName, ">", "", false);

					// If still not small enough, remove symbols one by one from right to left
					if (Len(LicensePlateName) > 8)
					{
						// Split into character array this way since Split() won't do this without crashing
						for (i=0; i<Len(LicensePlateName); i++)
							Characters[i] = Mid(LicensePlateName, i, 1);

						for (i=Characters.Length-1; i>=0; i--)
						{
							AscCode = Asc(Characters[i]);

							if (AscCode < 65 || AscCode > 90)
								Characters.Remove(i, 1);

							if (Characters.Length <= 8)
								break;
						}

						// If still not small enough, remove vowels one by one from right to left
						if (Characters.Length > 8)
						{
							for (i=Characters.Length-1; i>=0; i--)
							{
								AscCode = Asc(Characters[i]);

								switch(AscCode)
								{
									case 65:    Characters.Remove(i, 1);
												break;
									case 69:    Characters.Remove(i, 1);
												break;
									case 73:    Characters.Remove(i, 1);
												break;
									case 79:    Characters.Remove(i, 1);
												break;
									case 85:    Characters.Remove(i, 1);
												break;
								}

								if (Characters.Length <= 8)
									break;
							}
						}

						// Rebuild the string from all our munging
						LicensePlateName = "";
						for (i=0; i<Characters.Length; i++)
							LicensePlateName $= Characters[i];
					}
					// You can't say I didn't try, but just in case your name is insane...
					LicensePlateName = Left(LicensePlateName, 8);
				}
				LicensePlate.Revision++;
			}
	}
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	local int SizeX,  SizeY;
	local color BackColor, ForegroundColor, HighLightColor;

	HighLightColor.R=255;
	HighLightColor.G=255;
	HighLightColor.B=255;
	HighLightColor.A=255;

	ForegroundColor.R=220;
	ForegroundColor.G=210;
	ForegroundColor.B=230;
	ForegroundColor.A=255;

	BackColor.R=128;
	BackColor.G=128;
	BackColor.B=128;
	BackColor.A=0;

	Tex.TextSize(LicensePlateName, LicensePlateFont, SizeX, SizeY);
	Tex.DrawTile(0, 0, Tex.USize, Tex.VSize, 0, 0, Tex.USize, Tex.VSize, LicensePlateBackground, BackColor);
	Tex.DrawText(((Tex.USize - SizeX) * 0.5) - 1, 40 - 1, LicensePlateName, LicensePlateFont, HighLightColor);
	Tex.DrawText((Tex.USize - SizeX) * 0.5, 40, LicensePlateName, LicensePlateFont, ForegroundColor);
}

simulated event Destroyed()
{
	if (LicensePlate != None)
	{
		LicensePlate.Client = None;
		Level.ObjectPool.FreeObject(LicensePlate);
	}

	Super.Destroyed();
}

defaultproperties
{
	TeamShader(0)=Shader'CDOMGameTextures.xMonitor.RedScreenS'
	TeamShader(1)=Shader'CDOMGameTextures.xMonitor.BlueScreenS'
	TeamShader(2)=Shader'CDOMGameTextures.xMonitor.GreenTeamScreenS'
	TeamShader(3)=Shader'CDOMGameTextures.xMonitor.GoldTeamScreenS'
	TeamShader(4)=Shader'CDOMGameTextures.xMonitor.NeutralTeamScreenS'
	TeamShader(5)=Shader'XGameTextures.SuperPickups.BlackScreenS'
	NewTeam=255
	LicensePlate=ScriptedTexture'CDOMGameTextures.Textures.MonitorScreen'
	LicensePlateFallBack=Texture'CDOMGameTextures.Textures.MonitorBackground'
	LicensePlateBackground=Texture'CDOMGameTextures.Textures.MonitorBackground'
	Team=255
	StaticMesh=StaticMesh'CDOM-GameMeshes.Deco.MonitorDMesh'
	DrawScale=0.750000
}

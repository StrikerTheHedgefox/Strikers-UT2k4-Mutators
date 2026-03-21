class PackageManager extends Mutator
	config(SMPackageManager);

struct MutatorPackagesStruct
{
    var() config string Mutator;
    var() config string ServerPackages;
};

struct GameTypePackagesStruct
{
    var() config string GameType;
    var() config string ServerPackages;
};

var() config array<MutatorPackagesStruct> MutPackages;
var() config array<GameTypePackagesStruct> GamePackages;
var() config array<string> ServerPackage;
var() config array<string> LoadMutator;
var() config bool bIsInitialized;

function PostBeginPlay()
{
	local Mutator M;
	local int i;
	local int CommaPos;
	local string RawString, CurrentItem;
	local MutatorPackagesStruct MutP;
	local GameTypePackagesStruct GameTypeP;
	
	Super.PostBeginPlay();
	
	if (!bIsInitialized)
    {
		MutP.Mutator="BallisticProV55.Mut_BallisticPro";
		MutP.ServerPackages="BallisticProV55,BCoreProV55,BWBP_JCF_Pro,BWBP_OP_Pro,BWBP_SKC_Pro,BWBP_SWC_Pro,BWBP_VPC_Pro,BWBPAirstrikesPro,BWInteractions3,GunGameBW,HUDFix,Infestation,unrealextension";
		MutPackages[0] = MutP;
		
		MutP.Mutator="ChaosGames.ChaosUT";
		MutP.ServerPackages="AntiDareDevilMSG,ChaosGames,ChaosUT";
		MutPackages[1] = MutP;
		
		MutP.Mutator="ChaosUT2Interactions.MutCUT2Interactions";
		MutP.ServerPackages="ChaosUT2Interactions,unrealextension";
		MutPackages[2] = MutP;
		
		MutP.Mutator="UT2k4ScoreRecovery_v3.MutUT2k4ScoreRecovery_v3";
		MutP.ServerPackages="UT2k4ScoreRecovery_v3";
		MutPackages[3] = MutP;
		
		MutP.Mutator="ServerLogo4b_SM.MutServerLogo";
		MutP.ServerPackages="ServerLogo4b_SM,SMTexturesV1";
		MutPackages[4] = MutP;
		
		MutP.Mutator="SMHitMarkers.DamageMarker";
		MutP.ServerPackages="SMHitMarkers";
		MutPackages[5] = MutP;
		
		GameTypeP.GameType="Invasion";
		GameTypeP.ServerPackages="DoomRagdolls.ka,Quake4Ragdolls.ka,QuakeRagdolls.ka,ComboNecrov3,satoreMonsterPackv120,DoomMonsterPackv3,QuakeMonstersv2,Quake4Monstersv1,Quake4MonsterRagdollsv1";
		GamePackages[0] = GameTypeP;
		
		ServerPackage[0] = "SybilMod";
		ServerPackage[1] = "Sybiltex";
		ServerPackage[2] = "Sybil.ka";
		
		LoadMutator[0]="SMHitMarkers.DamageMarker";
		LoadMutator[1]="UT2k4ScoreRecovery_v3.MutUT2k4ScoreRecovery_v3";
		LoadMutator[2]="ServerLogo4b_SM.MutServerLogo";
	
        bIsInitialized = true;
		
        SaveConfig(); // Saves the current property values to .ini ONCE
        Log("SMServerPackages: Initialized and Saved INI");
    }
	
	// Mutator loading
	for (i = 0; i < LoadMutator.Length; i++)
	{
		Log("Loading Mutator: " $ LoadMutator[i]);
		Level.Game.AddMutator(LoadMutator[i], true);
	}
	
	// Map Music
    AddToPackageMap(Level.Song$".ogg");
	
	// Individual Packages
	for (i = 0; i < ServerPackage.Length; i++)
	{
		Log("Adding to package map: " $ ServerPackage[i]);
		AddToPackageMap(ServerPackage[i]);
	}
	
	// GameType Packages
	for (i = 0; i < GamePackages.Length; i++)
	{	
		if (InStr(Level.Game.Class.Name, GamePackages[i].GameType) != -1)
		{
			Log("Entry" $ i $ ":" $ GamePackages[i].GameType $ ", " $ GamePackages[i].ServerPackages);
			
			RawString = GamePackages[i].ServerPackages;
			while (RawString != "")
			{
				CommaPos = InStr(RawString, ",");
				
				if (CommaPos != -1)
				{
					CurrentItem = Left(RawString, CommaPos);
					RawString = Mid(RawString, CommaPos + 1); // Move past the comma
				}
				else
				{
					// Last item
					CurrentItem = RawString;
					RawString = "";
				}
				
				// Process CurrentItem here
				Log("Adding to package map for active gametype: " $ CurrentItem);
				AddToPackageMap(CurrentItem);
			}
			
			break;
		}
	}
	
	// Mutator Packages
	for (M = Level.Game.BaseMutator; M != None; M = M.NextMutator)
    {
        // Check if it's the specific mutator by its class name	
		for (i = 0; i < MutPackages.Length; i++)
		{
			if (InStr(string(M.Class), MutPackages[i].Mutator) != -1)
			{
				Log("Entry" $ i $ ":" $ MutPackages[i].Mutator $ MutPackages[i].ServerPackages);
				
				RawString = MutPackages[i].ServerPackages;
				while (RawString != "")
				{
					CommaPos = InStr(RawString, ",");
					
					if (CommaPos != -1)
					{
						CurrentItem = Left(RawString, CommaPos);
						RawString = Mid(RawString, CommaPos + 1); // Move past the comma
					}
					else
					{
						// Last item
						CurrentItem = RawString;
						RawString = "";
					}
					
					// Process CurrentItem here
					Log("Adding to package map for active mutator: " $ CurrentItem);
					AddToPackageMap(CurrentItem);
				}
				
				break;
			}
		}
    }
	
    Destroy();
}

/*
function Timer()
{
	local Mutator M;
	local int i;
	local int CommaPos;
	local string RawString, CurrentItem;
}
*/

defaultproperties
{
	FriendlyName="[SM] Package Manager"
	Description="Autoloads other mutators and automatically manages server packages based on currently loaded mutators and gametypes. Mutator by StrikerTheHedgefox."
	bIsInitialized=false;
}
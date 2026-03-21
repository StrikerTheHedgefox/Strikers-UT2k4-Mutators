class DamageMarker extends xMutator;
var DamageMarkerInteraction DMI;

#exec AUDIO IMPORT FILE="HitSound.wav" NAME="HitSound" GROUP="Sounds"
#exec TEXTURE IMPORT NAME="Marker" FILE="Marker.tga" GROUP="Markers" FLAGS=2

// Called when mutator starts
function PostBeginPlay()
{ 
	local DamageMarkerGameRules G;
	G = spawn(class'DamageMarkerGameRules');

	if ( Level.Game.GameRulesModifiers == None )
		Level.Game.GameRulesModifiers = G;
	else    
		Level.Game.GameRulesModifiers.AddGameRules(G);
	
	Super.PostBeginPlay();
	
}

// Somehow this works with unrealextension, but the code commented out underneath doesn't work for shit.
simulated function ClientSideInitialization(PlayerController PC)
{
	DMI = DamageMarkerInteraction(AddAnInteraction(PC, string( class'DamageMarkerInteraction' )));
	if(DMI != None)
	{
		DMI.Marker = Self;
		PC.ClientMessage("DMI Registered.");
	}
}

function ModifyPlayer(Pawn Other)
{
    local PlayerController PC;
	local DamageMarkerReplication LRI;

    // Typecast to ensure it's a player
    PC = PlayerController(Other.Controller);
    
    if (PC != None)
    {
        // Check if we have already initialized this player
        if (!PC.bScriptInitialized) 
        {
            if (Level.NetMode != NM_Client)
			{
				LRI = spawn(class'DamageMarkerReplication', PC);
				LRI.NextReplicationInfo = PC.PlayerReplicationInfo.CustomReplicationInfo;
				PC.PlayerReplicationInfo.CustomReplicationInfo = LRI;
			}
            
            // Set flag so this doesn't run again for this player
            PC.bScriptInitialized = true; 
        }
    }
    
    // Call the next mutator in the chain
    Super.ModifyPlayer(Other);
}

/*
// This shit doesn't work for whatever fucking reason.
simulated function PostNetBeginPlay()
{
	Enable('Tick');
}

// This won't execute on clients for some buttshitfucking reason.
// Why does UT2004's scripting make me want to kill myself?
simulated function Tick(float DeltaTime)
{
    local PlayerController PC;

    if ( Level.NetMode == NM_DedicatedServer)
    {
        Disable('Tick');
		return;
    }

    PC = Level.GetLocalPlayerController();
    if (PC != None)
    {
        DMI = DamageMarkerInteraction(PC.Player.InteractionMaster.AddInteraction("DamageMarkerInteraction", PC.Player));
		DMI.Marker = Self;
        Disable('Tick');
    }
}
*/

defaultproperties
{
	bAddToServerPackages=True
    FriendlyName="[SM] Hit Markers & Sounds"
    Description="Adds a hit marker to the HUD and sound effects when hitting opponents. Mutator by StrikerTheHedgefox."
}
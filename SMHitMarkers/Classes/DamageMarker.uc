class DamageMarker extends Mutator;

#exec AUDIO IMPORT FILE="HitSound.wav" NAME="HitSound" GROUP="Sounds"
#exec TEXTURE IMPORT NAME="Marker" FILE="Marker.tga" GROUP="Markers" FLAGS=2

function PostBeginPlay()
{ 
    local GameRules G;
    
    G = spawn(class'DamageMarkerGameRules');

    if ( Level.Game.GameRulesModifiers == None )
        Level.Game.GameRulesModifiers = G;
    else    
        Level.Game.GameRulesModifiers.AddGameRules(G);
    
    Super.PostBeginPlay();
}

// Multi-pronged approach to getting this actor spawned.
// -----------------------------------------------------

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	local PlayerController PC;
	PC = PlayerController(Other);
	
	if (PC != None && FindReplicationActor(PC) == None)
	{
        Spawn(class'DamageMarkerReplication', PC);
		//Log("Spawning replicator for player.");
	}

    return Super.CheckReplacement(Other, bSuperRelevant);
}

// Gets fucked in UT:2341 due to lack of Super.ModifyPlayer(Other) in its chain.
/*
function ModifyPlayer(Pawn Other)
{
    local PlayerController PC;

    PC = PlayerController(Other.Controller);
    if (PC != None && FindReplicationActor(PC) == None)
	{
        Spawn(class'DamageMarkerReplication', PC);
		//Log("Spawning replicator for player.");
	}

    Super.ModifyPlayer(Other);
}
*/

// -----------------------------------------------------

function DamageMarkerReplication FindReplicationActor(PlayerController PC)
{
    local DamageMarkerReplication DMR;

    foreach DynamicActors(class'DamageMarkerReplication', DMR)
    {
        if (DMR.Owner == PC)
            return DMR;
    }

    return None;
}

defaultproperties
{
	bAddToServerPackages=True
	FriendlyName="[SM] Hit Markers & Sounds"
	Description="Adds a hit marker to the HUD and sound effects when hitting opponents. Mutator by StrikerTheHedgefox."
}
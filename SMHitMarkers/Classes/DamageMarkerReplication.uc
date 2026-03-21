class DamageMarkerReplication extends Actor;

var int HitCount;
var int LastHitCount;
var DamageMarkerInteraction DMI;

replication
{
    reliable if (bNetDirty && Role == ROLE_Authority)
        HitCount;
}

simulated function Tick(float DeltaTime)
{
    // Clean up if owner disconnected
    if (Role == ROLE_Authority && Owner == None)
    {
        Destroy();
        return;
    }

    if (Level.NetMode == NM_DedicatedServer)
        return;

    if (HitCount != LastHitCount)
    {
        LastHitCount = HitCount;

        if (Owner == Level.GetLocalPlayerController())
            TriggerClientMarker();
    }
}

simulated function TriggerClientMarker()
{
    local PlayerController PC;

    PC = PlayerController(Owner);
    if (PC == None)
        return;

    if (DMI == None)
        DMI = DamageMarkerInteraction(PC.Player.InteractionMaster.AddInteraction("SMHitMarkers.DamageMarkerInteraction", PC.Player));

    if (DMI != None)
        DMI.TriggerHitMarker();
}

// Called on server by GameRules
function ServerTriggerMarker()
{
    HitCount++;
}

defaultproperties
{
    bHidden=True
    bOnlyRelevantToOwner=True
    bAlwaysRelevant=False
    bOnlyDirtyReplication=True
    bSkipActorPropertyReplication=False
    NetUpdateFrequency=100
    RemoteRole=ROLE_SimulatedProxy
}
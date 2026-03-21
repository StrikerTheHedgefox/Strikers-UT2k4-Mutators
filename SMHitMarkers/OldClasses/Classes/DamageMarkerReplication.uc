class DamageMarkerReplication extends LinkedReplicationInfo;

var int markerTrigger;

replication {
    // Replicate from Server to Client
    reliable if (bNetDirty && Role == ROLE_Authority)
        markerTrigger;
}

simulated function DoMarker()
{	
	local DamageMarker Marker;
	local PlayerController PC;
		
	foreach DynamicActors(class'DamageMarker', Marker)
	{
		break;
	}
	
	PC = Level.GetLocalPlayerController();
	
	Marker.DMI.TriggerHitMarker();
}

simulated event PostNetReceive() {
    super.PostNetReceive();
    
    // Check if the counter changed
    if (markerTrigger != Default.markerTrigger) {
        DoMarker();
        markerTrigger = Default.markerTrigger;
    }
}

defaultproperties
{
	markerTrigger = 0;
}
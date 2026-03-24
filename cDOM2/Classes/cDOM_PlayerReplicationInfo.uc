//==============================================================================
// Cache the player's points and adrenaline, until either one reaches 1.0
// AdrenalineCounter would not be needed if Epic would fix their own code.
//==============================================================================
class cDOM_PlayerReplicationInfo extends xPlayerReplicationInfo;

var float StatScore, AdrenalineCounter;
var int DomPointCapture; // Track how many control point captures player had made, to be shown on the F3 scoreboard.

replication
{
	reliable if (Role == Role_Authority)
		StatScore, AdrenalineCounter, DomPointCapture;
}

defaultproperties
{
}

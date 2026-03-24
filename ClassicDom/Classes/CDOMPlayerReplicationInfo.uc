//========================================================================
// Cache the player's points and adrenaline, until either one reaches 1.0
// AdrenalineCounter would not be needed if Epic would fix their own code.
//========================================================================
class CDOMPlayerReplicationInfo extends xPlayerReplicationInfo;

var float StatScore, AdrenalineCounter;

replication
{
	reliable if (Role == Role_Authority)
		StatScore, AdrenalineCounter;
}

defaultproperties
{
}

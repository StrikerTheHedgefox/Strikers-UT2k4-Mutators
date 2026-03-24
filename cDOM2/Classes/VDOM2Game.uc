//=============================================================================
// Vehicle Domination 2
//=============================================================================
Class VDOM2Game extends cDOM2Game
	config;

var config bool bTeamLockedVehicles; // (true) Are vehicles locked for teams or (false) free for anyone (Default=False)
var(LoadingHints) private localized array<string> VDOMHints;

function GetServerInfo( out ServerResponseLine ServerState )
{
	Super(TeamGame).GetServerInfo(ServerState);
}

static function array<string> GetAllLoadHints(optional bool bThisClassOnly)
{
	local int i;
	local array<string> Hints;

	if ( !bThisClassOnly || default.VDOMHints.Length == 0 )
		Hints = Super.GetAllLoadHints();

	for ( i = 0; i < default.VDOMHints.Length; i++ )
		Hints[Hints.Length] = default.VDOMHints[i];

	return Hints;
}

defaultproperties
{
	VDOMHints(0)="You can capture Control Points while in a vehicle or on foot."
	bAdvertiseDDOM=False
	bAddCDOM2ServerName=False
	bAllowVehicles=True
	MapListType="cDOM2.MapListVDOM2Game"
	MapPrefix="VDOM"
	BeaconName="VDOM2"
	OtherMesgGroup="VehicleDomination2"
	GameName="Vehicle Domination 2"
	Description="Like traditional Classic Domination, only adding vehicles into the mix!"
	ScreenShotName="CDOM-Thumbnail.VDOMshots"
	DecoTextName="cDOM2.VDOM2Game"
	Acronym="VDOM2"
}

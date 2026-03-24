class ClassicDomMessage extends CriticalEventPlus;

var(Message) localized String ControlPointStr, ControlledByRed, ControlledByBlue, ControlledByGreen, ControlledByGold;
var(Message) color RedColor, BlueColor, GreenColor, GoldColor;

static function color GetColor(optional int Switch,optional PlayerReplicationInfo RelatedPRI_1,optional PlayerReplicationInfo RelatedPRI_2)
{
	local color TheColor;

	if (Switch == 0)
		TheColor = Default.RedColor;
	else if (Switch == 1)
		TheColor = Default.BlueColor;
	else if (Switch == 2)
		TheColor = Default.GreenColor;
	else if (Switch == 3)
		TheColor = Default.GoldColor;

	return TheColor;
}

// We use the Switch to pass in the TeamID
static function string GetString(optional int Switch,optional PlayerReplicationInfo RelatedPRI_1,optional PlayerReplicationInfo RelatedPRI_2,optional Object OptionalObject)
{
	local string msg;

	if (Switch == 0)
		msg = Default.ControlPointStr@"["$ClassicDomPoint(OptionalObject).PointName$"]"@Default.ControlledByRed;
	else if (Switch == 1)
		msg = Default.ControlPointStr@"["$ClassicDomPoint(OptionalObject).PointName$"]"@Default.ControlledByBlue;
	else if (Switch == 2)
		msg = Default.ControlPointStr@"["$ClassicDomPoint(OptionalObject).PointName$"]"@Default.ControlledByGreen;
	else if (Switch == 3)
		msg = Default.ControlPointStr@"["$ClassicDomPoint(OptionalObject).PointName$"]"@Default.ControlledByGold;

	return msg;
}

defaultproperties
{
	ControlPointStr="Control Point"
	ControlledByRed="now controlled by Red Team!"
	ControlledByBlue="now controlled by Blue Team!"
	ControlledByGreen="now controlled by Green Team!"
	ControlledByGold="now controlled by Gold Team!"
	RedColor=(R=255,A=220)
	BlueColor=(B=255,G=160,A=220)
	GreenColor=(G=255,A=220)
	GoldColor=(G=205,R=205,A=220)
	bIsPartiallyUnique=True
	bIsConsoleMessage=False
	Lifetime=2
	StackMode=SM_Down
	PosY=0.100000
}

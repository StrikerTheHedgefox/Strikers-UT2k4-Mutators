//==============================================================================
// !! Required Mutator for cDOM2 !! Includes Unlimited Translocator Mutator, and
// allows us to use the cDOM_PlayerReplicationInfo.
//==============================================================================
class cDOM2GameMut extends DMMutator
	HideDropDown
	CacheExempt;

var class<PlayerReplicationInfo> PRIClass;
var(Message) localized String TransItemName;
var() int RepAmmo;
var() float AmmoChargeMax, AmmoChargeRate, AmmoChargeF, AmmoMinReloadPct;
var() bool bShowChargingBar;
var string MutateInfoString;
var localized string mTitle, mLine, mVer, mUnlimTrans, mAwardAdren, mDevious, mCTeamSymb, mAdvertise, mAddServName, mLStatClass, mDebug, mTick;

/// <summary>
/// set bSuperRelevant to False if want the gameinfo's super.IsRelevant() function called to check on relevancy of this actor.
/// </summary>
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	// Needed for our cDOM_PlayerReplicationInfo to work
	if (Controller(Other) != None && MessagingSpectator(Other) == None)
		Controller(Other).PlayerReplicationInfoClass = PRIClass;

	if (Translauncher(Other) != None)
	{
		bSuperRelevant = 0;
		if (class'cDOM2Game'.default.bUnlimitedTranslocator)
		{
			TransLauncher(Other).AmmoChargeRate = AmmoChargeRate;
			Translauncher(Other).bShowChargingBar = bShowChargingBar;
			Translauncher(Other).AmmoChargeF = AmmoChargeF;
			Translauncher(Other).MinReloadPct = AmmoMinReloadPct;
			Translauncher(Other).AmmoChargeMax = AmmoChargeMax;
			Translauncher(Other).RepAmmo = RepAmmo;
			Translauncher(Other).Itemname = TransItemName;
		}
	}

	Super.CheckReplacement(Other, bSuperRelevant);
	return True;
}

/// <summary>
/// Show the user the advanced settings for cDOM2
/// </summary>
function Mutate(string MutateString, PlayerController Sender)
{
	if ( MutateString ~= MutateInfoString )
	{
		Sender.ClientMessage(mTitle);
		Sender.ClientMessage(mLine);
		Sender.ClientMessage(mVer$class'cDOM2Game'.default.CDOMVer);
		Sender.ClientMessage(mUnlimTrans$class'cDOM2Game'.default.bUnlimitedTranslocator);
		Sender.ClientMessage(mAwardAdren$class'cDOM2Game'.default.bAwardAdrenaline);
		Sender.ClientMessage(mDevious$class'cDOM2Game'.default.bDeviousBots);
		Sender.ClientMessage(mCTeamSymb$class'cDOM2Game'.default.bClassicTeamSymbols);
		Sender.ClientMessage(mAdvertise$class'cDOM2Game'.default.bAdvertiseDDOM);
		Sender.ClientMessage(mAddServName$class'cDOM2Game'.default.bAddCDOM2ServerName);
		Sender.ClientMessage(mLStatClass$class'cDOM2Game'.default.LocalStatsScreenClass);
		Sender.ClientMessage(mDebug$class'cDOM2Game'.Default.bDebugMode);
		Sender.ClientMessage(mTick$Sender.ConsoleCommand("GETCURRENTTICKRATE") );
	}

	if ( NextMutator != None )
		NextMutator.Mutate(MutateString, Sender);
}

defaultproperties
{
	PRIClass=Class'cDOM2.cDOM_PlayerReplicationInfo'
	TransItemName="Unlimited Translocator"
	RepAmmo=7
	AmmoChargeMax=7.000000
	AmmoChargeRate=7.000000
	AmmoChargeF=7.000000
	AmmoMinReloadPct=1.000000
	MutateInfoString="cdominfo"
	mTitle="Classic Domination 2 - Server Settings"
	mLine="======================================"
	mVer=" cDOM Version: "
	mUnlimTrans=" bUnlimitedTranslocator: "
	mAwardAdren=" bAwardAdrenaline: "
	mDevious=" bDeviousBots: "
	mCTeamSymb=" bClassicTeamSymbols: "
	mAdvertise=" bAdvertiseDDOM: "
	mAddServName=" bAddCDOM2ServerName: "
	mLStatClass=" LocalStatsScreenClass: "
	mDebug="  bDebugMode: "
	mTick=" Current TickRate: "
	bAlwaysRelevant=True
}

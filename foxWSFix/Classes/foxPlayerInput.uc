//Lazily hijacks PlayerInput to provide mod-independent FOV scaling for both PlayerController and Weapon
class foxPlayerInput extends PlayerInput within PlayerController
	config(User)
	transient;

var bool bDoInit;
var bool bDoErrorInit;

struct WeaponInfo
{
	var class<Weapon> WeaponClass;
	var vector DefaultPlayerViewOffset;
	var vector DefaultEffectOffset;
	var vector DefaultSmallViewOffset;
	var vector DefaultSmallEffectOffset;
};
var WeaponInfo CachedWeaponInfo;

var globalconfig bool bInputClassErrorCheck;

const DEGTORAD = 0.01745329251994329576923690768489; //Pi / 180
const RADTODEG = 57.295779513082320876798154814105; //180 / Pi

//fox: Check various PlayerController classes for correct InputClass (and possibly just add it if missing)
function CheckControllerInputClass(class<PlayerController> ControllerClass, string FriendlyName)
{
	if (ControllerClass.default.InputClass != class'foxPlayerInput') {
		ClientMessage("foxWSFix: " $ FriendlyName $ " InputClass is: " $ ControllerClass.default.InputClass);

		//Just add InputClass if missing
		if (ControllerClass.default.InputClass == None) {
			ClientMessage("foxWSFix: Attempting to add missing InputClass line...");
			ControllerClass.default.InputClass = class'foxPlayerInput';
			ControllerClass.static.StaticSaveConfig();
			ClientMessage("foxWSFix: " $ FriendlyName $ " InputClass is now: " $ ControllerClass.default.InputClass);
		}
		ClientMessage("foxWSFix: Please verify User.ini settings!");
	}
}

//fox: Hijack this to force FOV per current aspect ratio - done every frame as a lazy catch-all since we're only hooking clientside PlayerInput
event PlayerInput(float DeltaTime)
{
	Super.PlayerInput(DeltaTime);

	//Do initialization stuff here, since we don't have init events
	if (bDoInit) {
		bDoInit = false;

		//Check for errors if requested
		if (bInputClassErrorCheck
		&& (class'PlayerController'.default.InputClass != class'foxPlayerInput' || class'xPlayer'.default.InputClass != class'foxPlayerInput')) {
			if (bDoErrorInit && Level.TimeSeconds > 3f) {
				bDoErrorInit = false;
				ClientMessage("foxWSFix Warning: One or more errors occurred. To skip this error check, set bInputClassErrorCheck=false in User.ini");
				CheckControllerInputClass(class'PlayerController', "[Engine.PlayerController]");
				CheckControllerInputClass(class'xPlayer', "[XGame.xPlayer]");

				//Write settings to ini once if stuck on errors
				SaveConfig();
			}

			//Just bail here, resetting bDoInit so we don't do our normal hooks
			bDoInit = true;
			return;
		}

		//Write settings to ini if first run
		SaveConfig();
		return;
	}

	//Oh no! Work around weapon respawn bug where position isn't set correctly on respawn
	if (Pawn == None || Pawn.Weapon == None) {
		UpdateCachedWeaponInfo(None);
		return;
	}

	//Set weapon FOV as well - only once per weapon
	if (Pawn.Weapon.Class != CachedWeaponInfo.WeaponClass)
		ApplyWeaponFOV(Pawn.Weapon);
}

function ApplyWeaponFOV(Weapon Weap)
{
	local float ScaleFactor;

	//First reset our "default default" values before doing anything else
	UpdateCachedWeaponInfo(Weap);

	//Set the new FOV
	Weap.DisplayFOV = GetHorPlusFOV(Weap.default.DisplayFOV);

	//Fix bad DisplayFOV calculation in Pawn.CalcDrawOffset()
	ScaleFactor = Weap.DisplayFOV / Weap.default.DisplayFOV;
	Weap.default.PlayerViewOffset *= ScaleFactor;
	Weap.default.EffectOffset *= ScaleFactor;
	Weap.default.SmallViewOffset *= ScaleFactor;
	Weap.default.SmallEffectOffset *= ScaleFactor;

	//Must set OldMesh's values directly (if applicable)
	if (Weap.bUseOldWeaponMesh) {
		Weap.OldPlayerViewOffset = Weap.default.OldPlayerViewOffset * ScaleFactor;
		Weap.OldSmallViewOffset = Weap.default.OldSmallViewOffset * ScaleFactor;
		Weap.bInitOldMesh = true; //Force a ViewOffset update
	}
}
function UpdateCachedWeaponInfo(Weapon Weap)
{
	if (CachedWeaponInfo.WeaponClass != None) {
		//ClientMessage("UpdateCachedWeaponInfo from " $ CachedWeaponInfo.WeaponClass @ CachedWeaponInfo.WeaponClass.default.PlayerViewOffset);
		CachedWeaponInfo.WeaponClass.default.PlayerViewOffset = CachedWeaponInfo.DefaultPlayerViewOffset;
		CachedWeaponInfo.WeaponClass.default.EffectOffset = CachedWeaponInfo.DefaultEffectOffset;
		CachedWeaponInfo.WeaponClass.default.SmallViewOffset = CachedWeaponInfo.DefaultSmallViewOffset;
		CachedWeaponInfo.WeaponClass.default.SmallEffectOffset = CachedWeaponInfo.DefaultSmallEffectOffset;
	}
	if (Weap == None)
		CachedWeaponInfo.WeaponClass = None;
	else {
		//ClientMessage("UpdateCachedWeaponInfo to " $ Weap.Class @ Weap.default.PlayerViewOffset);
		CachedWeaponInfo.WeaponClass = Weap.Class;
		CachedWeaponInfo.DefaultPlayerViewOffset = Weap.default.PlayerViewOffset;
		CachedWeaponInfo.DefaultEffectOffset = Weap.default.EffectOffset;
		CachedWeaponInfo.DefaultSmallViewOffset = Weap.default.SmallViewOffset;
		CachedWeaponInfo.DefaultSmallEffectOffset = Weap.default.SmallEffectOffset;
	}
	default.CachedWeaponInfo = CachedWeaponInfo; //Persist across levels (as we're destroyed on transition)
}

//fox: Convert vFOV to hFOV (and vice versa)
function float hFOV(float BaseFOV, float AspectRatio)
{
	return 2 * ATan(Tan(BaseFOV / 2f) * AspectRatio, 1);
}
function float vFOV(float BaseFOV, float AspectRatio)
{
	return 2 * ATan(Tan(BaseFOV / 2f) / AspectRatio, 1);
}

//fox: Use screen aspect ratio to auto-generate a Hor+ FOV
function float GetHorPlusFOV(float BaseFOV)
{
    local GUIController C;

    C = GUIController(Player.GUIController);
    if(C == None || C.ResX == 0)
        return FClamp(RADTODEG * hFOV(vFOV(BaseFOV * DEGTORAD, 4/3f), 4/3f), 1, 170);
    return FClamp(RADTODEG * hFOV(vFOV(BaseFOV * DEGTORAD, 4/3f), float(C.ResX)/float(C.ResY)), 1, 170);
}

defaultproperties
{
	bDoInit=true
	bDoErrorInit=true
	bInputClassErrorCheck=true
}
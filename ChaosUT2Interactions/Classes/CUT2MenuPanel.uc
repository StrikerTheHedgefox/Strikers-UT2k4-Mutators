class CUT2MenuPanel extends MidGamePanel
   dependsOn(Interactions);

var automated KeyBindEdit e_BeltEdit;
var automated KeyBindEdit e_KickEdit;
var automated KeyBindEdit e_SprayPaintEdit;
var automated KeyBindEdit e_HookEdit;

var automated KeyBindEdit e_DropFlagEdit;
var automated KeyBindEdit e_ChangeAmmoEdit;
var automated KeyBindEdit e_WeaponOptionEdit;
var automated KeyBindEdit e_HookUpEdit;
var automated KeyBindEdit e_DropRelicEdit;

var automated GUILabel l_BeltLabel;
var automated GUILabel l_KickLabel;
var automated GUILabel l_SprayPaintLabel;
var automated GUILabel l_HookLabel;

var automated GUILabel l_DropFlagLabel;
var automated GUILabel l_ChangeAmmoLabel;
var automated GUILabel l_WeaponOptionLabel;
var automated GUILabel l_HookUpLabel;
var automated GUILabel l_DropRelicLabel;

var automated GUIEditBox b_Caption;

var localized string BeltText;
var localized string KickText;
var localized string SprayPaintText;
var localized string HookText;

var localized string ChangeAmmoText;
var localized string WeaponOptionText;
var localized string DropFlagText;
var localized string HookUpText;
var localized string DropRelicText;
var localized string CaptionText;

function InitComponent( GUIController InController, GUIComponent InOwner )
{
   b_Caption.Caption = CaptionText;
   l_BeltLabel.Caption = BeltText;
   l_KickLabel.Caption = KickText;
   l_SprayPaintLabel.Caption = SprayPaintText;
   l_HookLabel.Caption = HookText;
   
   l_DropFlagLabel.Caption = DropFlagText;
   l_ChangeAmmoLabel.Caption = ChangeAmmoText;
   l_WeaponOptionLabel.Caption = WeaponOptionText;
   l_HookUpLabel.Caption = HookUpText;
   l_DropRelicLabel.Caption = DropRelicText;
   Super.InitComponent(InController, InOwner);
}

function BeltKeyInit(out byte keyCode)
{
   keyCode = class'CUT2Interactions'.default.BeltKey;
}

function KickKeyInit(out byte keyCode)
{
   keyCode = class'CUT2Interactions'.default.KickKey;
}

function SprayPaintKeyInit(out byte keyCode)
{
   keyCode = class'CUT2Interactions'.default.SprayPaintKey;
}

function HookKeyInit(out byte keyCode)
{
   keyCode = class'CUT2Interactions'.default.HookKey;
}

function DropFlagKeyInit(out byte keyCode)
{
   keyCode = class'CUT2Interactions'.default.DropFlagKey;
}

function ChangeAmmoKeyInit(out byte keyCode)
{
   keyCode = class'CUT2Interactions'.default.ChangeAmmoKey;
}

function WeaponOptionKeyInit(out byte keyCode)
{
   keyCode = class'CUT2Interactions'.default.WeaponOptionKey;
}

function HookUpKeyInit(out byte keyCode)
{
   keyCode = class'CUT2Interactions'.default.HookUpKey;
}

function DropRelicKeyInit(out byte keyCode)
{
	keyCode = class'CUT2Interactions'.default.DropRelicKey;
}

function BeltKeyChanged(byte keyCode)
{
   class'CUT2Interactions'.default.BeltKey = EInputKey(keyCode);
   class'CUT2Interactions'.static.StaticSaveConfig();
}

function KickKeyChanged(byte keyCode)
{
   class'CUT2Interactions'.default.KickKey = EInputKey(keyCode);
   class'CUT2Interactions'.static.StaticSaveConfig();
}

function SprayPaintKeyChanged(byte keyCode)
{
   class'CUT2Interactions'.default.SprayPaintKey = EInputKey(keyCode);
   class'CUT2Interactions'.static.StaticSaveConfig();
}

function HookKeyChanged(byte keyCode)
{
   class'CUT2Interactions'.default.HookKey = EInputKey(keyCode);
   class'CUT2Interactions'.static.StaticSaveConfig();
}

function DropFlagKeyChanged(byte keyCode)
{
   class'CUT2Interactions'.default.DropFlagKey = EInputKey(keyCode);
   class'CUT2Interactions'.static.StaticSaveConfig();
}

function ChangeAmmoKeyChanged(byte keyCode)
{
   class'CUT2Interactions'.default.ChangeAmmoKey = EInputKey(keyCode);
   class'CUT2Interactions'.static.StaticSaveConfig();
}

function WeaponOptionKeyChanged(byte keyCode)
{
   class'CUT2Interactions'.default.WeaponOptionKey = EInputKey(keyCode);
   class'CUT2Interactions'.static.StaticSaveConfig();
}

function HookUpKeyChanged(byte keyCode)
{
   class'CUT2Interactions'.default.HookUpKey = EInputKey(keyCode);
   class'CUT2Interactions'.static.StaticSaveConfig();
}

function DropRelicKeyChanged(byte keyCode)
{
   class'CUT2Interactions'.default.DropRelicKey = EInputKey(keyCode);
   class'CUT2Interactions'.static.StaticSaveConfig();
}

defaultproperties
{
	Begin Object Class=KeyBindEdit Name=BeltEdit
		OnInitKey=CUT2MenuPanel.BeltKeyInit
		OnKeyChanged=CUT2MenuPanel.BeltKeyChanged
		WinTop=0.090000
		WinLeft=0.550000
		WinWidth=0.150000
		WinHeight=0.040000
		OnActivate=BeltEdit.InternalActivate
		OnDeActivate=BeltEdit.InternalDeactivate
		OnClick=BeltEdit.MouseClick
		OnKeyType=BeltEdit.InternalOnKeyType
		OnKeyEvent=BeltEdit.InternalOnKeyEvent
	End Object
	e_BeltEdit=KeyBindEdit'ChaosUT2Interactions.CUT2MenuPanel.BeltEdit'

	Begin Object Class=KeyBindEdit Name=KickEdit
		OnInitKey=CUT2MenuPanel.KickKeyInit
		OnKeyChanged=CUT2MenuPanel.KickKeyChanged
		WinTop=0.155000
		WinLeft=0.550000
		WinWidth=0.150000
		WinHeight=0.040000
		OnActivate=KickEdit.InternalActivate
		OnDeActivate=KickEdit.InternalDeactivate
		OnClick=KickEdit.MouseClick
		OnKeyType=KickEdit.InternalOnKeyType
		OnKeyEvent=KickEdit.InternalOnKeyEvent
	End Object
	e_KickEdit=KeyBindEdit'ChaosUT2Interactions.CUT2MenuPanel.KickEdit'

	Begin Object Class=KeyBindEdit Name=SprayPaintEdit
		OnInitKey=CUT2MenuPanel.SprayPaintKeyInit
		OnKeyChanged=CUT2MenuPanel.SprayPaintKeyChanged
		WinTop=0.220000
		WinLeft=0.550000
		WinWidth=0.150000
		WinHeight=0.040000
		OnActivate=SprayPaintEdit.InternalActivate
		OnDeActivate=SprayPaintEdit.InternalDeactivate
		OnClick=SprayPaintEdit.MouseClick
		OnKeyType=SprayPaintEdit.InternalOnKeyType
		OnKeyEvent=SprayPaintEdit.InternalOnKeyEvent
	End Object
	e_SprayPaintEdit=KeyBindEdit'ChaosUT2Interactions.CUT2MenuPanel.SprayPaintEdit'

	Begin Object Class=KeyBindEdit Name=HookEdit
		OnInitKey=CUT2MenuPanel.HookKeyInit
		OnKeyChanged=CUT2MenuPanel.HookKeyChanged
		WinTop=0.290000
		WinLeft=0.550000
		WinWidth=0.150000
		WinHeight=0.040000
		OnActivate=HookEdit.InternalActivate
		OnDeActivate=HookEdit.InternalDeactivate
		OnClick=HookEdit.MouseClick
		OnKeyType=HookEdit.InternalOnKeyType
		OnKeyEvent=HookEdit.InternalOnKeyEvent
	End Object
	e_HookEdit=KeyBindEdit'ChaosUT2Interactions.CUT2MenuPanel.HookEdit'

	Begin Object Class=KeyBindEdit Name=DropFlagEdit
		OnInitKey=CUT2MenuPanel.DropFlagKeyInit
		OnKeyChanged=CUT2MenuPanel.DropFlagKeyChanged
		WinTop=0.360000
		WinLeft=0.550000
		WinWidth=0.150000
		WinHeight=0.040000
		OnActivate=DropFlagEdit.InternalActivate
		OnDeActivate=DropFlagEdit.InternalDeactivate
		OnClick=DropFlagEdit.MouseClick
		OnKeyType=DropFlagEdit.InternalOnKeyType
		OnKeyEvent=DropFlagEdit.InternalOnKeyEvent
	End Object
	e_DropFlagEdit=KeyBindEdit'ChaosUT2Interactions.CUT2MenuPanel.DropFlagEdit'

	Begin Object Class=KeyBindEdit Name=ChangeAmmoEdit
		OnInitKey=CUT2MenuPanel.ChangeAmmoKeyInit
		OnKeyChanged=CUT2MenuPanel.ChangeAmmoKeyChanged
		WinTop=0.430000
		WinLeft=0.550000
		WinWidth=0.150000
		WinHeight=0.040000
		OnActivate=ChangeAmmoEdit.InternalActivate
		OnDeActivate=ChangeAmmoEdit.InternalDeactivate
		OnClick=ChangeAmmoEdit.MouseClick
		OnKeyType=ChangeAmmoEdit.InternalOnKeyType
		OnKeyEvent=ChangeAmmoEdit.InternalOnKeyEvent
	End Object
	e_ChangeAmmoEdit=KeyBindEdit'ChaosUT2Interactions.CUT2MenuPanel.ChangeAmmoEdit'

	Begin Object Class=KeyBindEdit Name=WeaponOptionEdit
		OnInitKey=CUT2MenuPanel.WeaponOptionKeyInit
		OnKeyChanged=CUT2MenuPanel.WeaponOptionKeyChanged
		WinTop=0.500000
		WinLeft=0.550000
		WinWidth=0.150000
		WinHeight=0.040000
		OnActivate=WeaponOptionEdit.InternalActivate
		OnDeActivate=WeaponOptionEdit.InternalDeactivate
		OnClick=WeaponOptionEdit.MouseClick
		OnKeyType=WeaponOptionEdit.InternalOnKeyType
		OnKeyEvent=WeaponOptionEdit.InternalOnKeyEvent
	End Object
	e_WeaponOptionEdit=KeyBindEdit'ChaosUT2Interactions.CUT2MenuPanel.WeaponOptionEdit'

	Begin Object Class=KeyBindEdit Name=HookUpEdit
		OnInitKey=CUT2MenuPanel.HookUpKeyInit
		OnKeyChanged=CUT2MenuPanel.HookUpKeyChanged
		WinTop=0.570000
		WinLeft=0.550000
		WinWidth=0.150000
		WinHeight=0.040000
		OnActivate=HookUpEdit.InternalActivate
		OnDeActivate=HookUpEdit.InternalDeactivate
		OnClick=HookUpEdit.MouseClick
		OnKeyType=HookUpEdit.InternalOnKeyType
		OnKeyEvent=HookUpEdit.InternalOnKeyEvent
	End Object
	e_HookUpEdit=KeyBindEdit'ChaosUT2Interactions.CUT2MenuPanel.HookUpEdit'

	Begin Object Class=KeyBindEdit Name=DropRelicEdit
		OnInitKey=CUT2MenuPanel.DropRelicKeyInit
		OnKeyChanged=CUT2MenuPanel.DropRelicKeyChanged
		WinTop=0.640000
		WinLeft=0.550000
		WinWidth=0.150000
		WinHeight=0.040000
		OnActivate=DropRelicEdit.InternalActivate
		OnDeActivate=DropRelicEdit.InternalDeactivate
		OnClick=DropRelicEdit.MouseClick
		OnKeyType=DropRelicEdit.InternalOnKeyType
		OnKeyEvent=DropRelicEdit.InternalOnKeyEvent
	End Object
	e_DropRelicEdit=KeyBindEdit'ChaosUT2Interactions.CUT2MenuPanel.DropRelicEdit'

	Begin Object Class=GUILabel Name=BeltLabel
		TextColor=(B=255,G=255,R=255)
		WinTop=0.090000
		WinLeft=0.300000
		WinWidth=0.150000
		WinHeight=0.040000
	End Object
	l_BeltLabel=GUILabel'ChaosUT2Interactions.CUT2MenuPanel.BeltLabel'

	Begin Object Class=GUILabel Name=KickLabel
		TextColor=(B=255,G=255,R=255)
		WinTop=0.155000
		WinLeft=0.300000
		WinWidth=0.150000
		WinHeight=0.040000
	End Object
	l_KickLabel=GUILabel'ChaosUT2Interactions.CUT2MenuPanel.KickLabel'

	Begin Object Class=GUILabel Name=SprayPaintLabel
		TextColor=(B=255,G=255,R=255)
		WinTop=0.220000
		WinLeft=0.300000
		WinWidth=0.180000
		WinHeight=0.040000
	End Object
	l_SprayPaintLabel=GUILabel'ChaosUT2Interactions.CUT2MenuPanel.SprayPaintLabel'

	Begin Object Class=GUILabel Name=HookLabel
		TextColor=(B=255,G=255,R=255)
		WinTop=0.290000
		WinLeft=0.300000
		WinWidth=0.150000
		WinHeight=0.040000
	End Object
	l_HookLabel=GUILabel'ChaosUT2Interactions.CUT2MenuPanel.HookLabel'

	Begin Object Class=GUILabel Name=DropFlagLabel
		TextColor=(B=255,G=255,R=255)
		WinTop=0.360000
		WinLeft=0.300000
		WinWidth=0.150000
		WinHeight=0.040000
	End Object
	l_DropFlagLabel=GUILabel'ChaosUT2Interactions.CUT2MenuPanel.DropFlagLabel'

	Begin Object Class=GUILabel Name=ChangeAmmoLabel
		TextColor=(B=255,G=255,R=255)
		WinTop=0.430000
		WinLeft=0.300000
		WinWidth=0.150000
		WinHeight=0.040000
	End Object
	l_ChangeAmmoLabel=GUILabel'ChaosUT2Interactions.CUT2MenuPanel.ChangeAmmoLabel'

	Begin Object Class=GUILabel Name=WeaponOptionLabel
		TextColor=(B=255,G=255,R=255)
		WinTop=0.500000
		WinLeft=0.300000
		WinWidth=0.150000
		WinHeight=0.040000
	End Object
	l_WeaponOptionLabel=GUILabel'ChaosUT2Interactions.CUT2MenuPanel.WeaponOptionLabel'

	Begin Object Class=GUILabel Name=HookUpLabel
		TextColor=(B=255,G=255,R=255)
		WinTop=0.570000
		WinLeft=0.300000
		WinWidth=0.150000
		WinHeight=0.040000
	End Object
	l_HookUpLabel=GUILabel'ChaosUT2Interactions.CUT2MenuPanel.HookUpLabel'

	Begin Object Class=GUILabel Name=DropRelicLabel
		TextColor=(B=255,G=255,R=255)
		WinTop=0.640000
		WinLeft=0.300000
		WinWidth=0.150000
		WinHeight=0.040000
	End Object
	l_DropRelicLabel=GUILabel'ChaosUT2Interactions.CUT2MenuPanel.DropRelicLabel'

	Begin Object Class=GUIEditBox Name=MyBorder
		bReadOnly=True
		WinTop=0.025000
		WinLeft=0.010000
		WinWidth=0.980000
		WinHeight=0.040000
		bTabStop=False
		bNeverFocus=True
		OnActivate=MyBorder.InternalActivate
		OnDeActivate=MyBorder.InternalDeactivate
		OnKeyType=MyBorder.InternalOnKeyType
		OnKeyEvent=MyBorder.InternalOnKeyEvent
	End Object
	b_Caption=GUIEditBox'ChaosUT2Interactions.CUT2MenuPanel.MyBorder'

	BeltText="Use Belt"
	KickText="Kick"
	SprayPaintText="Spray Paint"
	HookText="Hook"
	ChangeAmmoText="Change Ammo"
	WeaponOptionText="Weapon Option"
	DropFlagText="Drop Flag"
	HookUpText="Hook Up"
	DropRelicText="Drop Relic"
	
	CaptionText="Key Assignments"
}

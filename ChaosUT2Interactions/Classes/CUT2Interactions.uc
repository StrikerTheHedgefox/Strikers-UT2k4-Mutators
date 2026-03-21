class CUT2Interactions extends Interaction
config(User);

var config bool bShowTabOnInit;

var config EInputKey BeltKey;
var config EInputKey KickKey;
var config EInputKey SprayPaintKey;
var config EInputKey HookKey;
var config EInputKey ChangeAmmoKey;
var config EInputKey WeaponOptionKey;
var config EInputKey DropFlagKey;
var config EInputKey HookUpKey;
var config EInputKey DropRelicKey;

var localized string MenuName;
var localized string MenuHelp;
var localized string ConfigBWText;

var bool bHookHeld, bHookUpHeld, bBeltHeld, bWeaponOptionHeld, bChangeAmmoHeld;

// Needed so that we don't call ModifyMenu again even when when it already added the new tab.
var private editconst bool bMenuModified;

event Initialized()
{	
	local UT2K4PlayerLoginMenu Menu;
			
	if (default.bShowTabOnInit)
	{
		if (!GUIController(ViewportOwner.Actor.Player.GUIController).OpenMenu(UnrealPlayer(ViewportOwner.Actor).LoginMenuClass))
			return;
		
		if(!bMenuModified)
			ModifyMenu();
		
		Menu = UT2K4PlayerLoginMenu(GUIController(ViewportOwner.Actor.Player.GUIController).FindPersistentMenuByName( UnrealPlayer(ViewportOwner.Actor).LoginMenuClass ));
		if( Menu != none )
		{
			Menu.c_Main.ActivateTabByName(MenuName, true);
			
			class'CUT2Interactions'.default.bShowTabOnInit = false;
			class'CUT2Interactions'.static.StaticSaveConfig();
			
			GUIController(ViewportOwner.Actor.Player.GUIController).OpenMenu("GUI2K4.GUI2K4QuestionPage");
			GUIQuestionPage(GUIController(ViewportOwner.Actor.Player.GUIController).TopPage()).SetupQuestion(ConfigBWText, 1, 1);
		}
	}
}

final private function ModifyMenu()
{
   local UT2K4PlayerLoginMenu Menu;
   local GUITabPanel Panel;

   // Try get the menu, will return none if the menu is not open!.
   Menu = UT2K4PlayerLoginMenu(GUIController(ViewportOwner.Actor.Player.GUIController).FindPersistentMenuByName( UnrealPlayer(ViewportOwner.Actor).LoginMenuClass ));
   if( Menu != none )
   {
		log("ChaosUT2Interactions: Menu found");
      // You can use the panel reference to do the modifications to the tab etc.
     Panel = Menu.c_Main.AddTab(MenuName, string( class'CUT2MenuPanel' ),, MenuHelp);
      bMenuModified = true;

      // Uncomment if tick is not needed for anything else than ModifyMenu.
      Disable('Tick');
      bRequiresTick = false;
   }
}

function Tick( float DeltaTime )
{
   if( !bMenuModified )
      ModifyMenu();
}

function bool KeyEvent(EInputKey Key, EInputAction Action, FLOAT Delta )
{
	if (ViewPortOwner.Actor.Pawn == None && Key != class'CUT2Interactions'.default.DropFlagKey)
		return Super.KeyEvent(Key,Action,Delta);    
	else
	{
		if ((Action == IST_Press) && (Key == class'CUT2Interactions'.default.BeltKey))
		{
			if(!bBeltHeld)
			{
				ConsoleCommand("mutate UseBelt");
				bBeltHeld = true;
			}
			return true;
		}
		else if ((Action == IST_Release) && (Key == class'CUT2Interactions'.default.BeltKey))
		{
			bBeltHeld = false;
			return true;
		}
		
		if ((Action == IST_Press) && (Key == class'CUT2Interactions'.default.KickKey))
		{
			ConsoleCommand("mutate Kick");
			return true;
		}
		
		if ((Action == IST_Press) && (Key == class'CUT2Interactions'.default.DropRelicKey))
		{
			ConsoleCommand("mutate DropRelic");
			return true;
		}
		
		if ((Action == IST_Press) && (Key == class'CUT2Interactions'.default.DropFlagKey))
		{
			ConsoleCommand("dropflag");
			return true;
		}
		
		if ((Action == IST_Press) && (Key == class'CUT2Interactions'.default.ChangeAmmoKey))
		{
			if(!bChangeAmmoHeld)
			{
				ConsoleCommand("changeammo");
				bChangeAmmoHeld = true;
			}
			return true;
		}
		else if ((Action == IST_Release) && (Key == class'CUT2Interactions'.default.ChangeAmmoKey))
		{
			bChangeAmmoHeld = false;
			return true;
		}
		
		if ((Action == IST_Press) && (Key == class'CUT2Interactions'.default.SprayPaintKey))
		{
			ConsoleCommand("mutate SprayPaint");
			return true;
		}
		
		if ((Action == IST_Press) && (Key == class'CUT2Interactions'.default.HookKey))
		{
			if(!bHookHeld)
			{
				ConsoleCommand("mutate Hook");
				bHookHeld = true;
			}
			return true;
		}
		else if ((Action == IST_Release) && (Key == class'CUT2Interactions'.default.HookKey))
		{
	        bHookHeld = false;
			return true;
		}
		
		if ((Action == IST_Press) && (Key == class'CUT2Interactions'.default.WeaponOptionKey))
		{
			if(!bWeaponOptionHeld)
			{
				ConsoleCommand("ChaosWeaponOption");
				bWeaponOptionHeld = true;
			}
			return true;
		}
		else if ((Action == IST_Release) && (Key == class'CUT2Interactions'.default.WeaponOptionKey))
		{
			bWeaponOptionHeld = false;
			return true;
		}
		
		if ((Action == IST_Press) && (Key == class'CUT2Interactions'.default.HookUpKey))
		{
			if(!bHookUpHeld)
			{
				ConsoleCommand("mutate HookUp");
				bHookUpHeld = true;
			}
			return true;
		}
		else if ((Action == IST_Release) && (Key == class'CUT2Interactions'.default.HookUpKey))
		{
			bHookUpHeld = false;
		}
	}
      
	return Super.KeyEvent(Key,Action,Delta);

}

//remove myself if level changed
event NotifyLevelChange()
{
	local UT2K4PlayerLoginMenu LoginMenu;
	
	//remove the tab
	foreach AllObjects(class'UT2K4PlayerLoginMenu', LoginMenu)
		LoginMenu.c_Main.RemoveTab(MenuName);

   Master.RemoveInteraction(self);
}

defaultproperties
{
	bShowTabOnInit=True
	
	BeltKey=IK_B
	KickKey=IK_Q
	SprayPaintKey=IK_L
	HookKey=IK_F
	ChangeAmmoKey=IK_R
	WeaponOptionKey=IK_Z
	DropFlagKey=IK_X
	HookUpKey=IK_G
	DropRelicKey=IK_N
	
	MenuName="ChaosUT2 Binds"
	MenuHelp="ChaosUT2 Bind Menu"
	ConfigBWText="Please set ChaosUT2 keys. Keys set affect this server only and do not overwrite."
	bVisible=True
	bRequiresTick=True
}

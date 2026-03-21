//=============================================================================
// MutServerLogo
// Copyright (c) 2004 by Wormbo <wormbo@onlinehome.de>
//
// Spawns the ServerLogo actor.
//=============================================================================


class MutServerLogo extends Mutator;


//=============================================================================
// PostBeginPlay
//
// Spawn the ServerLogo actor if it doesn't already exist.
//=============================================================================

function PostBeginPlay()
{
  local ServerLogo S;
  
  LifeSpan = 0.01;  // destroy the mutator afterwards
  
  foreach DynamicActors(class'ServerLogo', S)
    return;
  
  Spawn(class'ServerLogo');
}


//=============================================================================
// GetServerDetails
//
// Don't show in server details.
//=============================================================================

function GetServerDetails(out GameInfo.ServerResponseLine ServerState);


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
	bAddToServerPackages=True
	GroupName="ServerLogo"
	FriendlyName="Server Logo 4b [SM]"
	Description="Displays a logo on clients that connected to the server."
}

class MutSingleTapDodge extends Mutator;

var float PostLandCooldown;

function PostBeginPlay()
{
	Super.PostBeginPlay();
}

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	local PlayerController PC;
	PC = PlayerController(Other);
	
	if (PC != None && FindReplicationActor(PC) == None)
	{
		Spawn(class'InteractionHooker', PC);
		//Log("Spawning replicator for player.");
	}

	return Super.CheckReplacement(Other, bSuperRelevant);
}

function InteractionHooker FindReplicationActor(PlayerController PC)
{
	local InteractionHooker IH;

	foreach DynamicActors(class'InteractionHooker', IH)
	{
		if (IH.Owner == PC)
			return IH;
	}

	return None;
}

defaultproperties
{
	bAddToServerPackages=True
	GroupName="SingleDodge"
	FriendlyName="Single Tap Dodge"
	PostLandCooldown=0.5
}
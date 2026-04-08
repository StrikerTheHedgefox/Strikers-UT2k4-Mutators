class MutGoombaStomp extends Mutator;

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	local PlayerController PC;
	local Actor GSTActor;
	PC = PlayerController(Other);
	
	if (PC != None && FindReplicationActor(PC) == None)
	{
		GSTActor = Spawn(class'GoombaStompTracker', PC);
		GSTActor.SetBase(Other);
		
		//Log("Spawning replicator for player.");
	}

	return Super.CheckReplacement(Other, bSuperRelevant);
}

function GoombaStompTracker FindReplicationActor(PlayerController PC)
{
	local GoombaStompTracker GST;

	foreach DynamicActors(class'GoombaStompTracker', GST)
	{
		if (GST.Owner == PC)
			return GST;
	}

	return None;
}

defaultproperties
{
	bAddToServerPackages=True
	FriendlyName="[SM] Goomba Stomp"
	Description="Adds a goomba stomp mechanic. Mutator by StrikerTheHedgefox."
}
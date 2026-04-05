class MutGoombaStomp extends Mutator;

function ModifyPlayer(Pawn Other)
{
    local GoombaStompTracker T;

    Super.ModifyPlayer(Other);

    if (Other == None)
        return;

    // Spawn tracker and attach to player
    T = Spawn(class'GoombaStompTracker', Other);
    if (T != None)
    {
        T.SetOwner(Other);
        T.SetBase(Other);
        T.OwnerPawn = Other;
    }
}

defaultproperties
{
	bAddToServerPackages=True
	FriendlyName="[SM] Goomba Stomp"
	Description="Adds a goomba stomp mechanic. Mutator by StrikerTheHedgefox."
}
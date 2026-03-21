class MutCUT2Interactions extends xMutator
	transient;

simulated function ClientSideInitialization(PlayerController PC)
{
	AddAnInteraction(PC, string( class'CUT2Interactions' ));
}

defaultproperties
{
	FriendlyName="ChaosUT2: Bind Menu"
	Description="Adds bind support to ChaosUT2."
}

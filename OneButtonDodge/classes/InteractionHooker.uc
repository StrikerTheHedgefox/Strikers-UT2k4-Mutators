class InteractionHooker extends ReplicationInfo
    placeable;

var bool bReceivedVars;

simulated function PostNetBeginPlay()
{
	bReceivedVars = True;
	Enable('Tick');
}

simulated function Tick(float DeltaTime)
{
	local PlayerController LocalPlayer;
	local Interaction MyInteraction;

	if ( !bReceivedVars || Level.NetMode == NM_DedicatedServer ) {
		Disable('Tick');
		return;
	}

	LocalPlayer = Level.GetLocalPlayerController();
	if ( LocalPlayer != None )
		MyInteraction = LocalPlayer.Player.InteractionMaster.AddInteraction(string(class'SingleDodgeInteraction'), LocalPlayer.Player);

	Disable('Tick');
}

defaultproperties
{
	bReceivedVars = False;
}
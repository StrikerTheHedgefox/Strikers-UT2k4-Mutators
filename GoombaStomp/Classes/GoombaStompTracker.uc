class GoombaStompTracker extends Actor;

#exec AUDIO IMPORT FILE="Stomp.wav" NAME="Stomp" GROUP="Sounds"

var bool bReceivedVars;

var float TraceDistance;
var float MinDownwardVelocity;
var float StompHeightThreshold;
var int   TraceResolution;    // number of traces around circumference

var sound StompSound;

replication
{
	reliable if (Role < ROLE_Authority)
		DoStomp;
}

simulated function PostNetBeginPlay()
{
	bReceivedVars = True;
	Enable('Tick');
}

simulated function Tick(float DeltaTime)
{	
	local vector Start, End, HitLocation, HitNormal, Offset;
	local Actor HitActor;
	local Pawn Victim;
	local int i;
	local float AngleRad;
	
	local PlayerController PC;

	// Purge if player disconnected.
	if (Role == ROLE_Authority && Owner == None)
	{
		Destroy();
		return;
	}	
	
	PC = PlayerController(Owner);

	if (PC.Pawn == None)
		return;

	if (PC.Pawn.Velocity.Z > MinDownwardVelocity)
		return; // only falling

	// Main trace straight down
	Start = PC.Pawn.Location;
	End   = Start - vect(0,0,1) * TraceDistance;
	HitActor = PC.Trace(HitLocation, HitNormal, End, Start, true);
	Victim = Pawn(HitActor);
	if (CheckStomp(Victim))
		return;

	// Extra traces around player circumference
	for (i = 0; i < TraceResolution; i++)
	{
		AngleRad = (360.0 / TraceResolution) * i * (3.14159265/180); // convert to radians

		Offset.X = cos(AngleRad) * PC.Pawn.CollisionRadius;
		Offset.Y = sin(AngleRad) * PC.Pawn.CollisionRadius;
		Offset.Z = 0.0;

		Start = PC.Pawn.Location + Offset;
		End   = Start - vect(0,0,1) * TraceDistance;

		HitActor = PC.Trace(HitLocation, HitNormal, End, Start, true);
		Victim = Pawn(HitActor);
		if (CheckStomp(Victim))
			return;
	}
}

simulated function bool CheckStomp(Pawn Victim)
{
	local PlayerController PC;	
	PC = PlayerController(Owner);
	
	if (Victim == None || Victim == PC.Pawn)
		return false;
	
	if (Level.Game.bTeamGame)
	{
		if (PC.Pawn.GetTeamNum() == Victim.GetTeamNum())
			return false;
	}
	
	if(Victim.IsA('Vehicle'))
		return false;

	if ((PC.Pawn.Location.Z - Victim.Location.Z) < StompHeightThreshold)
		return false;
		
	if (Victim.Health <= 0)
		return false;
	
	TriggerStomp(Victim);
	
	return true;
}

simulated function StompLogic(Pawn Victim)
{
	local PlayerController PC;
	PC = PlayerController(Owner);
	
	if (Victim == None || PC.Pawn == None)
		return;
	
	if (StompSound != None && PC.Pawn != None)
		PC.Pawn.PlayOwnedSound(StompSound, SLOT_None, 1.0, false, 300);

	if(Role == ROLE_Authority)
	{
		Victim.TakeDamage(
			1000,
			PC.Pawn,
			Victim.Location,
			vect(0,0,0),
			class'DamTypeGoombaStomp'
		);
	}
		
	PC.Pawn.Velocity.Z = 600;
}

simulated function DoStomp(Pawn Victim)
{
	if(Role == ROLE_Authority)
		StompLogic(Victim);
}

// Proxy function so we can predict the stomp logic.
simulated function TriggerStomp(Pawn Victim)
{
	local PlayerController PC;
	PC = PlayerController(Owner);
	if(PC.Pawn == None)
		return;
	
	if(PC.Level.NetMode != NM_DedicatedServer)
	{
		StompLogic(Victim);
		DoStomp(Victim);
	}
	else
	{
		if(PC.Pawn.IsA('Bot'))
		{
			StompLogic(Victim);
		}
	}
}

defaultproperties
{
	bReceivedVars=False
	bHidden=True
	bOnlyRelevantToOwner=False
	bAlwaysRelevant=False
	bOnlyDirtyReplication=False
	bSkipActorPropertyReplication=False
	NetUpdateFrequency=100
	RemoteRole=ROLE_SimulatedProxy
	
	TraceDistance=60.0
	TraceResolution=8
	StompHeightThreshold=40.0
	MinDownwardVelocity=-200.0

	StompSound=Sound'Sounds.Stomp'
}
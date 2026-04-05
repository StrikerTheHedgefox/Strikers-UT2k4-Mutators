class GoombaStompTracker extends Actor;

#exec AUDIO IMPORT FILE="Stomp.wav" NAME="Stomp" GROUP="Sounds"

var Pawn OwnerPawn;

// Tunables
var float TraceDistance;
var float MinDownwardVelocity;
var float StompHeightThreshold;

// Sound
var sound StompSound;

replication
{
    reliable if (Role < ROLE_Authority)
        ServerDoStomp;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    SetTimer(0.0, true); // ensures Tick runs
}

simulated event Tick(float DeltaTime)
{
    local vector Start, End, HitLocation, HitNormal;
    local Actor HitActor;
    local Pawn Victim;

    if (OwnerPawn == None)
        return;

    // Only while falling
    if (OwnerPawn.Velocity.Z > MinDownwardVelocity)
        return;

    Start = OwnerPawn.Location;
    End   = Start - vect(0,0,1) * TraceDistance;

    HitActor = Trace(HitLocation, HitNormal, End, Start, true);

    Victim = Pawn(HitActor);

    if (Victim == None || Victim == OwnerPawn)
        return;

    if (!IsValidPlayerPawn(Victim))
        return;

    if (!IsValidPlayerPawn(OwnerPawn))
        return;
		
	if (OwnerPawn.Team == Victim.Team)
        return;

    // Height check
    if ((OwnerPawn.Location.Z - Victim.Location.Z) < StompHeightThreshold)
        return;

    // CLIENT-SIDE prediction
    if (Role < ROLE_Authority)
    {
        PlayStompEffects();
        ServerDoStomp(Victim);
    }
    else
    {
        DoStomp(Victim);
    }
}

function bool IsValidPlayerPawn(Pawn P)
{
    return (P != None && P.Controller != None && P.Controller.bIsPlayer);
}

function ServerDoStomp(Pawn Victim)
{
    DoStomp(Victim);
}

function DoStomp(Pawn Victim)
{
    if (Victim == None || OwnerPawn == None)
        return;

    if (Victim.Health <= 0)
        return;

    // Server-side validation (IMPORTANT)
    if ((OwnerPawn.Location.Z - Victim.Location.Z) < StompHeightThreshold)
        return;

    if (OwnerPawn.Velocity.Z > MinDownwardVelocity)
        return;
		
	if (OwnerPawn.Team == Victim.Team)
        return;

    // Effects (server will replicate sound to others)
    PlayStompEffects();

    // Kill victim
    Victim.TakeDamage(
        1000,
        OwnerPawn,
        Victim.Location,
        vect(0,0,0),
        class'DamTypeGoombaStomp'
    );

    // Bounce
    OwnerPawn.Velocity.Z = 400;
}

simulated function PlayStompEffects()
{
    if (StompSound != None && OwnerPawn != None)
    {
        OwnerPawn.PlaySound(StompSound, SLOT_Interact, 1.0,, 1000);
    }
}

defaultproperties
{
    bHidden=true
    bAlwaysTick=true
    RemoteRole=ROLE_SimulatedProxy

    TraceDistance=60.0
    StompHeightThreshold=40.0
    MinDownwardVelocity=-150.0

    StompSound=Sound'Sounds.Stomp'
}
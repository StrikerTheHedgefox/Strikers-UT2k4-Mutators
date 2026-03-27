class MutSingleTapDodge extends Mutator;

var bool bHasInteraction;

function PostBeginPlay()
{
	local InteractionHooker IH;
	
	Super.PostBeginPlay();
	Enable('Tick');
	
	foreach DynamicActors(class'InteractionHooker', IH)
		return;
		
	Spawn(class'InteractionHooker');

}

function Tick(float DeltaTime)
{
	/*
	local Controller C;
	local int PID;

	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		if (C.Pawn == None || PlayerController(C) == None)
			continue;
	}
	*/
}

static function bool AttemptDodge(Pawn P, Controller C)
{
	local vector X, Y, Z, DodgeDir, DirCross, TraceStart, TraceEnd, HitLocation, HitNormal;
	local Actor HitActor;
	local float FDot, SDot;
	local eDoubleClickDir ClickDir;
	local bool DidDodge;

	if (P == None || C == None)
		return false;
	
	if (P.bIsCrouched || P.bWantsToCrouch || (P.Physics != PHYS_Walking && P.Physics != PHYS_Falling))
		return false;
	
	if (VSize(P.Acceleration) < 0.1)
		return false;

	if (P.Physics == PHYS_Falling)
	{
		if(!P.bCanWallDodge)
			return false;
						
		TraceStart = P.Location - P.CollisionHeight*Vect(0,0,1);
		TraceEnd = TraceStart - Normal(P.Acceleration)*(32.0 + P.CollisionRadius);
		
		HitActor = P.Trace(HitLocation, HitNormal, TraceEnd, TraceStart, false, vect(1,1,1));
		
		if (HitActor == None || (!HitActor.bWorldGeometry && (Mover(HitActor) == None))) 
			return false;
	}

	C.GetAxes(P.Rotation, X, Y, Z);
	FDot = Normal(P.Acceleration) Dot X;
	SDot = Normal(P.Acceleration) Dot Y;
	DodgeDir = Normal(X * FDot + Y * SDot);

	if (Abs(FDot) > Abs(SDot)) {
		if (FDot > 0) ClickDir = DCLICK_Forward; else ClickDir = DCLICK_Back;
		DirCross = DodgeDir Cross Y;
	} else {
		if (SDot > 0) ClickDir = DCLICK_Right; else ClickDir = DCLICK_Left;
		DirCross = DodgeDir Cross X;
	}

	DidDodge = xPawn(P).PerformDodge(ClickDir, DodgeDir, DirCross);
	if(DidDodge)
		PlayerController(C).DoubleClickDir = DCLICK_Active;
	
	return DidDodge; 
}

function Mutate(string MutateString, PlayerController Sender)
{
	if (MutateString ~= "dodge" && Sender != None && Sender.Pawn != None)
	{
		if (Sender.DoubleClickDir == DCLICK_Active || Sender.DoubleClickDir == DCLICK_Done)
			return;

		AttemptDodge(Sender.Pawn, Sender);
	}
	Super.Mutate(MutateString, Sender);
}

defaultproperties
{
	bAddToServerPackages=True
	GroupName="SingleDodge"
	FriendlyName="Single Tap Dodge"
}
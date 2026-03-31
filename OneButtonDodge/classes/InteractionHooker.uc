class InteractionHooker extends Actor;

var SingleDodgeInteraction MyInteraction;
var bool bReceivedVars;
var float LandTime;
var bool bWaitingToLand;

replication
{
	reliable if (Role < ROLE_Authority)
		DoDodge;
}

simulated function PostNetBeginPlay()
{
	bReceivedVars = True;
	Enable('Tick');
}

simulated function bool DodgeLogic()
{
	local vector X, Y, Z, DodgeDir, DirCross, TraceStart, TraceEnd, HitLocation, HitNormal;
	local Actor HitActor;
	local float FDot, SDot;
	local eDoubleClickDir ClickDir;
	local bool DidDodge;
	
	local PlayerController PC;
	local Pawn P;
	
	if(Owner == None)
		return false;
		
	PC = PlayerController(Owner);
	P = PC.Pawn;
	
	if (P == None || PC == None)
		return false;
	
	if (P.bIsCrouched || P.bWantsToCrouch || (P.Physics != PHYS_Walking && P.Physics != PHYS_Falling))
	{
		//P.ClientMessage("Failing on block A " $ Role);
		return false;
	}
	
	if (VSize(P.Acceleration) < 0.1)
	{
		//P.ClientMessage("Failing on block B " $ Role);
		return false;
	}
	
	if (PC.DoubleClickDir == DCLICK_Active)
	{
		//P.ClientMessage("Failing on block C " $ Role);
		return false;
	}
	
	// HACK:	This mispredicts online for some buttfucking reason. So don't do it on the server.
	//			If anyone has a solution, I'm open to contributions.
	if(PC.Level.NetMode != NM_DedicatedServer)
	{
		if(PC.Level.TimeSeconds - LandTime < class'MutSingleTapDodge'.default.PostLandCooldown)
		{
			//P.ClientMessage("Failing on block D " $ Role);
			return false;
		}
	}

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

	PC.GetAxes(P.Rotation, X, Y, Z);
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
	{
		PC.DoubleClickDir = DCLICK_Active;
	}
	
	return DidDodge;
}

simulated function DoDodge()
{
	if(Role == ROLE_Authority)
		DodgeLogic();
}

// Proxy function so we can predict the dodge logic.
simulated function TriggerDodge()
{
	if(DodgeLogic())
		DoDodge();
}

simulated function Tick(float DeltaTime)
{
	local PlayerController PC;
	PC = PlayerController(Owner);
	if (PC == None)
		return;

	if(MyInteraction == None && Level.NetMode != NM_DedicatedServer && bReceivedVars)
	{
		if ( PC != None )
		{
			MyInteraction = SingleDodgeInteraction(PC.Player.InteractionMaster.AddInteraction(string(class'SingleDodgeInteraction'), PC.Player));
			MyInteraction.IH = self;
			//log("Got Interaction");
			//PC.ClientMessage("Got Interaction!");
		}
	}
	
	// Try to prevent chaining doubletaps with singletaps to bypass cooldown.
	if(PC.DoubleClickDir == DCLICK_Active)
		bWaitingToLand = true;
	
	// Brutal shitty hack to get around the fact that DCLICK_Done isn't properly reset serverside.
	if(bWaitingToLand && PC.Pawn.Physics == PHYS_Walking)
	{
		LandTime = Level.TimeSeconds;
		bWaitingToLand = false;
	}
}

defaultproperties
{
	bReceivedVars = False;
	bHidden=True
	bOnlyRelevantToOwner=True
	bAlwaysRelevant=False
	bOnlyDirtyReplication=False
	bSkipActorPropertyReplication=False
	NetUpdateFrequency=100
	RemoteRole=ROLE_SimulatedProxy
}
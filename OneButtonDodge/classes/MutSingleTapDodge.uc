class MutSingleTapDodge extends Mutator;

struct PlayerStatus {
    var float LandTime;
    var bool bWaitingForLand;
};

var array<PlayerStatus> Stats;
var config float PostLandCooldown;
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
    local Controller C;
    local int PID;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        if (C.Pawn == None || PlayerController(C) == None)
			continue;
		
        PID = C.PlayerReplicationInfo.PlayerID;
        if (Stats.Length <= PID)
			Stats.Length = PID + 1;
		
		// Prevent chaining double-tap and single-tap to work around the cooldown.
		if(PlayerController(C).DoubleClickDir == DCLICK_Active)
			Stats[PID].bWaitingForLand = true;

        if (Stats[PID].bWaitingForLand)
        {
            if (C.Pawn.Physics == PHYS_Walking)
            {	
                Stats[PID].bWaitingForLand = false;
                Stats[PID].LandTime = Level.TimeSeconds;
            }
        }
    }
}

static function bool AttemptDodge(Pawn P, Controller C)
{
    local vector X, Y, Z, DodgeDir, DirCross;
    local float FDot, SDot;
    local eDoubleClickDir ClickDir;

    if (P == None || C == None) return false;
    if (P.Physics != PHYS_Walking && P.Physics != PHYS_Falling) return false;
    if (VSize(P.Acceleration) < 0.1) return false;

    if (P.Physics == PHYS_Falling)
    {
        if (P.Trace(X, Y, P.Location - (Normal(P.Acceleration) * 64), P.Location, true) == None) 
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

    return xPawn(P).PerformDodge(ClickDir, DodgeDir, DirCross);
}

function Mutate(string MutateString, PlayerController Sender)
{
    local int PID;
    if (MutateString ~= "dodge" && Sender != None && Sender.Pawn != None)
    {
        PID = Sender.PlayerReplicationInfo.PlayerID;
        if (Stats.Length <= PID) Stats.Length = PID + 1;

        if (Stats[PID].bWaitingForLand)
			return;
        if (Level.TimeSeconds - Stats[PID].LandTime < PostLandCooldown)
			return;

        if (static.AttemptDodge(Sender.Pawn, Sender))
        {
            Stats[PID].bWaitingForLand = true;
        }
    }
    Super.Mutate(MutateString, Sender);
}

defaultproperties
{
	bAddToServerPackages=True
    PostLandCooldown=0.5
    GroupName="SingleDodge"
    FriendlyName="Single Tap Dodge"
}
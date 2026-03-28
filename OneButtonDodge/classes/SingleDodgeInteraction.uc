class SingleDodgeInteraction extends Interaction;

var float FrictionScale; // e.g., 0.5 for half speed
var float LandTime;

function Initialize()
{
	Log("SingleDodgeInteraction Initialized on Client!");
}

function Remove()
{
	Master.RemoveInteraction(Self);
}

event NotifyLevelChange()
{
	Remove();
}

exec function DoDodge()
{
	local PlayerController PC;
	
	PC = ViewportOwner.Actor;

	if (PC == None || PC.Pawn == None)
		return;
	
	if (PC.Level.TimeSeconds - LandTime < class'MutSingleTapDodge'.default.PostLandCooldown)
		return;
	
	// Predict locally
	if (class'MutSingleTapDodge'.static.AttemptDodge(PC.Pawn, PC))
	{
		PC.ConsoleCommand("mutate dodge");
	}
}

function Tick(float DeltaTime)
{
	local PlayerController PC;
	
	PC = ViewportOwner.Actor;
	if(PC == None)
		return;
	
	if (PC.DoubleClickDir == DCLICK_Done)
    {	
        LandTime = PC.Level.TimeSeconds;
    }
}

/*
function bool KeyEvent(out EInputKey Key, out EInputAction Action, float Delta)
{
	local PlayerController PC;
	local Rotator NewRot;
	local Actor Target;
	local vector StartTrace, EndTrace, HitLocation, HitNormal;

	PC = ViewportOwner.Actor;

	// Check if this is a mouse or joystick movement axis
	if (Action == IST_Axis && (Key == IK_JoyR || Key == IK_JoyU))
	{
		// 1. Perform Trace to detect target
		StartTrace = PC.Pawn.Location + PC.Pawn.EyePosition();
		EndTrace = StartTrace + vector(PC.Rotation) * 5000;
		Target = PC.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

		// 2. If target is an enemy, manually scale the rotation
		if (Pawn(Target) != None && Pawn(Target).Health > 0)
		{
			NewRot = PC.Rotation;
			
			if (Key == IK_JoyR)
				NewRot.Yaw += Delta * FrictionScale;
			else if (Key == IK_JoyU)
				NewRot.Pitch += Delta * FrictionScale;

			PC.SetRotation(NewRot);
			
			// Return true to tell the engine WE handled the input
			return true; 
		}
	}

	return Super.KeyEvent(Key,Action,Delta);
}
*/

defaultproperties
{
	FrictionScale = 0.5
	bRequiresTick = True
	bActive = True
	bVisible = True
}
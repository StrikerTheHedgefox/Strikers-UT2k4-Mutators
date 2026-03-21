class DamageMarkerInteraction extends Interaction;

var float HitMarkerDuration;
var float HitMarkerMaxSize;
var float HitMarkerMinSize;
var float HitMarkerStartTime;
var float HitMarkerEndTime;

const STY_Alpha = 5;

simulated function TriggerHitMarker()
{
    HitMarkerStartTime = ViewportOwner.Actor.Level.TimeSeconds;
    HitMarkerEndTime = ViewportOwner.Actor.Level.TimeSeconds + HitMarkerDuration;
    ViewportOwner.Actor.ClientPlaySound(Sound'HitSound');
}

function Remove()
{
    Master.RemoveInteraction(Self);
}

event NotifyLevelChange()
{
    Remove();
}

static function float GetTimeAlpha(float StartTime, float EndTime, float CurrentTime)
{
    local float Alpha;

    if (EndTime <= StartTime)
        return 1.0;

    Alpha = (CurrentTime - StartTime) / (EndTime - StartTime);

    if (Alpha < 0.0)
        Alpha = 0.0;
    else if (Alpha > 1.0)
        Alpha = 1.0;

    return Alpha;
}

function PostRender(Canvas C)
{
    local float X, Y, Scale, SizeX, SizeY, ratio;
    local float Alpha;
    local float Time;
    local Texture MyTex;
    
    Time = ViewportOwner.Actor.Level.TimeSeconds;

    if (Time < HitMarkerStartTime || Time >= HitMarkerEndTime || HitMarkerStartTime == 0 || HitMarkerEndTime == 0)
        return;
        
    Alpha = 1.0 - GetTimeAlpha(HitMarkerStartTime, HitMarkerEndTime, Time);
    if(Alpha <= 0)
        return;
        
    MyTex = Texture'Marker';

    X = C.ClipX / 2;
    Y = C.ClipY / 2;

    Scale = HitMarkerMinSize + (HitMarkerMaxSize - HitMarkerMinSize) * Alpha;
    
    ratio = float(C.SizeX) / float(C.SizeY);
    SizeX = Scale * (C.SizeX / (768.0 * ratio));
    SizeY = Scale * (C.SizeY / 768.0);

    C.Style = STY_Alpha;
    C.SetDrawColor(255,255,255, Alpha * 255);

    X -= SizeX * 0.5;
    Y -= SizeY * 0.5;
    
    C.SetPos(X, Y);
    C.DrawTileClipped(MyTex, SizeX, SizeY, 0, 0, MyTex.USize, MyTex.VSize);
}

defaultproperties
{
    bActive=True;
    bVisible=True;
    
    HitMarkerDuration = 0.5;
    HitMarkerMaxSize = 64;
    HitMarkerMinSize = 16;
    HitMarkerStartTime = 0.0;
    HitMarkerEndTime = 0.0;
}
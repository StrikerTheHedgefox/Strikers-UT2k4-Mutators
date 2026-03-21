class DamageMarkerGameRules extends GameRules;

function int NetDamage( int OriginalDamage, int Damage, Pawn Victim, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
    local PlayerController PC;
    local DamageMarkerReplication DMR;

    if( ( InstigatedBy != None )
        //&& ( class<WeaponDamageType>(DamageType) != None || class<VehicleDamageType>(DamageType) != None )
      )
    {
        PC = PlayerController(InstigatedBy.Controller);
        if(PC != None && InstigatedBy.IsPlayerPawn() && (Victim != InstigatedBy))
        {
            if ( !(Level.Game.bTeamGame && Victim.GetTeamNum() == InstigatedBy.GetTeamNum()) )
            {
                DMR = FindReplicationActor(PC);
                if (DMR != None)
				{
					//Log("Hit!");
                    DMR.ServerTriggerMarker();
				}
            }
        }
    }

    if ( NextGameRules != None )
        return NextGameRules.NetDamage( OriginalDamage,Damage,Victim,InstigatedBy,HitLocation,Momentum,DamageType );
    else
        return Damage;
}

function DamageMarkerReplication FindReplicationActor(PlayerController PC)
{
    local DamageMarkerReplication DMR;

    foreach DynamicActors(class'DamageMarkerReplication', DMR)
    {
        if (DMR.Owner == PC)
            return DMR;
    }

    return None;
}

defaultproperties
{
}
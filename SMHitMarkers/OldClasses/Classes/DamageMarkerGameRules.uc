class DamageMarkerGameRules extends GameRules;

function int NetDamage( int OriginalDamage, int Damage, Pawn Victim, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	local PlayerController PC;
	local LinkedReplicationInfo LRI;
	
    // Check to get rid of the "Accessed Nones" in the server-log
    if( ( InstigatedBy != None )  &&
	    ( class<WeaponDamageType>(DamageType) != None || class<VehicleDamageType>(DamageType) != None )
	  )
    {
		PC = PlayerController(InstigatedBy.Controller);
		if(PC != None)
		{		
			// Tell the client to indicate to the instigator that he inflicted damage, unless it was self-damage
			if ( InstigatedBy.IsPlayerPawn() && (Victim != InstigatedBy) )
			{
				// Check if you hit a teammate (or a teamvehicle) in a team game
				if ( (Level.Game.bTeamGame) && (Victim.GetTeamNum() == InstigatedBy.GetTeamNum()) )	// GetTeamNum takes care of vehicles too
				{
					// Hit teammate.
				}
				// Otherwise, you hit the enemy.
				else 
				{	
					if (PC.PlayerReplicationInfo != None)
					{
						// 2. Start at the head of the custom replication chain
						LRI = PC.PlayerReplicationInfo.CustomReplicationInfo;

						// 3. Traverse the list to find your custom class
						while (LRI != None)
						{
							if (DamageMarkerReplication(LRI) != None)
							{
								// 4. Call the function on the server; it will replicate to the client
								DamageMarkerReplication(LRI).markerTrigger = 1;
								break; 
							}
							LRI = LRI.NextReplicationInfo;
						}
					}
				}
			}
		}
    }

    if ( NextGameRules != None )
    { 
        return NextGameRules.NetDamage( OriginalDamage,Damage,Victim,InstigatedBy,HitLocation,Momentum,DamageType );
    }
    else
    {
        return Damage;
    }
}

defaultproperties
{
}
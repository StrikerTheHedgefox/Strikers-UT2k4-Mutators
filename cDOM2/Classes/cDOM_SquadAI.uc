Class cDOM_SquadAI extends DOMSquadAI;

// <BeDevious>
//    <summary>
//    return true if bot should use guile in hunting opponent (more expensive)
//    </summary>
//    <returns>bool</returns>
function bool BeDevious()
{
	if ( Class'cDOM2Game'.default.bDeviousBots )
		return True;
	else
		return False;
}
// </BeDevious>

function name GetOrders()
{
	local name NewOrders;

	if (PlayerController(SquadLeader) != None)
		NewOrders = 'Human';
	else if ( bFreelance && cDOM_TeamAI(Team.AI).StayFreelance(self) )
		NewOrders = 'Freelance';
	else if ( (SquadObjective != None) && (SquadObjective.DefenderTeamIndex == Team.TeamIndex) )
		NewOrders = 'Defend';
	else
		NewOrders = 'Attack';
	if (NewOrders != CurrentOrders)
	{
		CurrentOrders = NewOrders;
		NetUpdateTime = Level.Timeseconds - 1;
	}
	return CurrentOrders;
}

function byte PriorityObjective(Bot B)
{
	return 2;
}

defaultproperties
{
	MaxSquadSize=2
}

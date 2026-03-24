Class cDOM_TeamAI extends DOMTeamAI;

function GameObjective FindNearestDomPoint(SquadAI S)
{
	local float BestWeight, NewWeight;
	local GameObjective O, Best;

	BestWeight = 10000000;
	for (O=Objectives; O!=None; O=O.NextObjective)
	{
		if (DominationPoint(O) != None)
		{
			if (O.DefenderTeamIndex == 255)
				NewWeight = VSize(O.Location - S.LeaderPRI.Location) * 0.1;
			else if ( O.DefenderTeamIndex == Team.TeamIndex )
			{
				NewWeight = VSize(O.location - S.LeaderPRI.Location) + 2 * Abs(O.Location.Z - S.LeaderPRI.Location.Z);
				NewWeight *= (0.8 + 0.4 * FRand());
			}
			else
				NewWeight = 90000000;

			if (NewWeight < BestWeight)
			{
				BestWeight = NewWeight;
				Best = O;
			}
		}
	}

	return Best;
}

function GameObjective Find2ndNearestDomPoint(SquadAI S, GameObjective FirstGameO)
{
	local float BestWeight, NewWeight;
	local GameObjective O, Best;

	BestWeight = 10000000;
	for (O=Objectives; O!=None; O=O.NextObjective)
	{
		if ( (DominationPoint(O) != None) && (O != FirstGameO) )
		{
			if (O.DefenderTeamIndex == 255)
				NewWeight = VSize(O.Location - S.LeaderPRI.Location) * 0.1;
			else if ( O.DefenderTeamIndex == Team.TeamIndex )
			{
				NewWeight = VSize(O.location - S.LeaderPRI.Location) + 2 * Abs(O.Location.Z - S.LeaderPRI.Location.Z);
				NewWeight *= (0.8 + 0.4 * FRand());
			}
			else
				NewWeight = 90000000;

			if (NewWeight < BestWeight)
			{
				BestWeight = NewWeight;
				Best = O;
			}
		}
	}

	return Best;
}

/* ReAssessStrategy()
Look at current strategic situation, and decide whether to update squad objectives  */
function ReAssessStrategy()
{
	local GameObjective O;
	local int PlusDiff, MinusDiff;

	if (FreelanceSquad == None)
		return;

	// decide whether to play defensively or aggressively
	PlusDiff = 0;
	MinusDiff = 4;
	if (DeathMatch(Level.Game).RemainingTime < 0.25 * Level.Game.TimeLimit)
	{
		if (DeathMatch(Level.Game).RemainingTime < 0.1 * Level.Game.TimeLimit)
			MinusDiff = 0;
		else
			MinusDiff = 2;
	}

	FreelanceSquad.bFreelanceAttack = false;
	FreelanceSquad.bFreelanceDefend = false;
	if (Team.Score > EnemyTeam.Score + PlusDiff)
	{
		FreelanceSquad.bFreelanceDefend = true;
		O = GetLeastDefendedObjective();
	}
	else if (Team.Score < EnemyTeam.Score - MinusDiff)
	{
		FreelanceSquad.bFreelanceAttack = true;
		O = GetPriorityAttackObjectiveFor(FreelanceSquad);
	}
	else
		O = GetPriorityFreelanceObjective();

	if ( (O != None) && (O != FreelanceSquad.SquadObjective) )
		FreelanceSquad.SetObjective(O,true);
}

function FindNewObjectiveFor(SquadAI S, bool bForceUpdate)
{
	local GameObjective O;
	local GameObjective GameObj[2];

	if (PlayerController(S.SquadLeader) != None)
		return;

	if (S != None)
	{
		GameObj[0] = FindNearestDomPoint(S);
		if (GameObj[0] != None)
			GameObj[1] = Find2ndNearestDomPoint(S, GameObj[0]);
	}
	if (S.bFreelance)
	{
		O = GetPriorityFreelanceObjective();
		if ( (GameObj[0] != None && O == GameObj[0]) || (GameObj[1] != None && O == GameObj[1]) )
		{
			if (O != None)
				S.SetObjective(O, bForceUpdate);
			else
				Super.FindNewObjectiveFor(S, bForceUpdate);

			return;
		}
		else
			O = Super.GetPriorityFreelanceObjective();
	}
	else if (S.SquadObjective != None)
		O = S.SquadObjective;
	else if (S.GetOrders() == 'Attack')
	{
		O = GetPriorityAttackObjectiveFor(S);
		if ( (GameObj[0] != None && O == GameObj[0]) || (GameObj[1] != None && O == GameObj[1]) )
		{
			if (O != None)
				S.SetObjective(O, bForceUpdate);
			else
				super.FindNewObjectiveFor(S, bForceUpdate);

			return;
		}
		else
			O = Super.GetPriorityAttackObjectiveFor(S);
	}
	else if (S.GetOrders() == 'Defend')
	{
		O = GetLeastDefendedObjective();
		if ( (GameObj[0] != None && O == GameObj[0]) || (GameObj[1] != None && O == GameObj[1]) )
		{
			if (O != None)
				S.SetObjective(O, bForceUpdate);
			else
				super.FindNewObjectiveFor(S, bForceUpdate);

			return;
		}
		else
			O = Super.GetLeastDefendedObjective();
	}

	if (O == None)
	{
		if ( rand(20) < 10 )
			Super.FindNewObjectiveFor(S,bForceUpdate);
		else
			O = GetRandomObjective(S);
	}
	if (O != None)
		S.SetObjective(O, bForceUpdate);
	else
		Super.FindNewObjectiveFor(S, bForceUpdate);
}

function GameObjective GetRandomObjective(SquadAI S)
{
	local int i, c;
	local GameObjective O;
	local array<xDomPoint> DP;

	c = 0;
	for (O=Objectives; O!=None; O=O.NextObjective)
	{
		if (xDomPoint(O) != None)
		{
			DP[c] = xDomPoint(O);
			c++;
		}
	}

	i = rand(c);
	if ( (DP[i] != None) && (DP[i].DefenderTeamIndex != S.Team.TeamIndex) )
		return DP[i];
	else
	{
		i = rand(c);
		if ( (DP[i] != None) && (DP[i].DefenderTeamIndex != S.Team.TeamIndex) )
			return DP[i];
		else
			return DP[rand(c)];
	}
}

function GameObjective GetLeastDefendedObjective()
{
	local GameObjective O, Best;
	local float BestI;

	for (O=Objectives; O!=None; O=O.NextObjective)
	{
			if ( !O.bObsolete && O.IsA('cDOM_DomPoint') && (((Best == None) || (O.DefenderTeamIndex == 255) || (Best.DefensePriority < O.DefensePriority)
					|| ((Best.DefensePriority == O.DefensePriority) && (Best.GetNumDefenders() < O.GetNumDefenders())))
				|| ((BestI > cDOM_DomPoint(O).HolderTimer) && (O.DefenderTeamIndex == Team.TeamIndex))) )
			{
				Best = O;
				BestI = cDOM_DomPoint(O).HolderTimer;
			}
			else if ( (DominationPoint(O) != None) && DominationPoint(O).CheckPrimaryTeam(Team.TeamIndex)
			&& ((Best == None) || (Best.DefensePriority < O.DefensePriority)
				|| ((Best.DefensePriority == O.DefensePriority) && (Best.GetNumDefenders() < O.GetNumDefenders()))) )
				Best = O;
	}

	return Best;
}

function GameObjective GetPriorityAttackObjectiveFor(SquadAI AttackSquad)
{
	local GameObjective O, Best;
	local float BestI;

	for (O=Objectives; O!=None; O=O.NextObjective)
	{
		if ( !O.bObsolete && O.IsA('cDOM_DomPoint') && ((DominationPoint(O) != None) && !DominationPoint(O).CheckPrimaryTeam(Team.TeamIndex)
			&& ((Best == None) || (Best.DefenderTeamIndex == Team.TeamIndex && BestI > cDOM_DomPoint(O).HolderTimer)
			|| (Best.DefenderTeamIndex == Team.TeamIndex))) )
		{
			Best = O;
			BestI = cDOM_DomPoint(O).HolderTimer;
		}
		else if ( (DominationPoint(O) != None) && !DominationPoint(O).CheckPrimaryTeam(Team.TeamIndex)
		&& ((Best == None) || (Best.DefenderTeamIndex == Team.TeamIndex)) )
			Best = O;
	}

	return Best;
}

function GameObjective GetPriorityFreelanceObjective()
{
	local GameObjective O, Best;
	local float BestI;

	for (O=Objectives; O!=None; O=O.NextObjective)
	{
		if ( !O.bObsolete && O.IsA('cDOM_DomPoint') && ((Best == None) || (O.DefenderTeamIndex == 255) || ((BestI > cDOM_DomPoint(O).HolderTimer)
			&& (O.DefenderTeamIndex == Team.TeamIndex) )) )
		{
			Best = O;
			BestI = cDOM_DomPoint(O).HolderTimer;
		}
		else if ( (DominationPoint(O) != None) && ((Best == None) || (Best.DefenderTeamIndex == Team.TeamIndex)) )
		{
			Best = O;
		}
	}

	return Best;
}

function SetOrders(Bot B, name NewOrders, Controller OrderGiver)
{
	local GameObjective O;
	local TeamPlayerReplicationInfo PRI;
	local byte Picked;

	PRI = TeamPlayerReplicationInfo(B.PlayerReplicationInfo);
	if (HoldSpot(B.GoalScript) != None)
	{
		PRI.bHolding = false;
		B.FreeScript();
	}
	if (NewOrders == 'Hold')
	{
		PRI.bHolding = true;
		PutBotOnSquadLedBy(OrderGiver,B);
		B.GoalScript = PlayerController(OrderGiver).ViewTarget.Spawn(class'HoldSpot');
		if ( Vehicle(PlayerController(OrderGiver).ViewTarget) != None )
			HoldSpot(B.GoalScript).HoldVehicle = Vehicle(PlayerController(OrderGiver).ViewTarget);
		if ( PlayerController(OrderGiver).ViewTarget.Physics == PHYS_Ladder )
			B.GoalScript.SetPhysics(PHYS_Ladder);

		return;
	}
	Picked = 255;
	if (NewOrders == 'Defend')
		Picked = 1;
	else if (NewOrders == 'Attack')
		Picked = 0;

	if (Picked == 255)
		Super.SetOrders(B,NewOrders,OrderGiver);
	else
	{
		if ( (PrimaryDefender != None) && (DominationPoint(PrimaryDefender.SquadObjective).PrimaryTeam == Picked) )
			PrimaryDefender.AddBot(B);
		else if ( (AttackSquad != None) && (DominationPoint(AttackSquad.SquadObjective).PrimaryTeam == Picked) )
			AttackSquad.AddBot(B);
		else
		{
			// find objective, and add new squad
			for ( O=Objectives; O!=None; O=O.NextObjective )
				if ( (DominationPoint(O) != None) && (DominationPoint(O).PrimaryTeam == Picked) )
					break;

			if (DominationPoint(O) != None)
			{
				if (PrimaryDefender == None)
					PrimaryDefender = AddSquadWithLeader(B, O);
				else if (AttackSquad == None)
					AttackSquad = AddSquadWithLeader(B, O);
			}
		}
	}
}

defaultproperties
{
	SquadType=Class'cDOM2.cDOM_SquadAI'
}

class MinPlayersFixer extends Mutator;

var config int bareMinimumPlayers;
var config int countAlgorithm;
var config bool bInitialized;


var Deathmatch DM;
var int minPlayers;
var int maxPlayers;
var int wantedPlayers;
function PostBeginPlay()
{	
	DM = Deathmatch(Level.Game);
	if(DM == None)
		return;
	if(DM.bPlayersVsBots)
		return;
		
	minPlayers = Level.IdealPlayerCountMin;
	maxPlayers = Level.IdealPlayerCountMax;
	
	if(countAlgorithm == 1)
		wantedPlayers = (minPlayers + maxPlayers)/2;
	else
		wantedPlayers = minPlayers;
	
	if((wantedPlayers < bareMinimumPlayers) || Level.Game.IsA('Invasion'))
		wantedPlayers = bareMinimumPlayers;
	
	DM.bAutoNumBots = false;
	DM.InitialBots = wantedPlayers;
	DM.MinPlayers = wantedPlayers;
	
	Super.PostBeginPlay();
	
	if(!bInitialized)
	{
		bInitialized = true;
		SaveConfig();
	}
	
	//log("Recommended Player Count: " $ minPlayers $ " - " $ maxPlayers $ ", Desired: " $ wantedPlayers $ ");
	//SetTimer(1.0, True); // Run every 0.1 seconds (10 times per second)
}


/*
function bool NeedPlayers()
{
    return ((DM.NumPlayers + DM.NumBots) < wantedPlayers);
}

function bool TooManyPlayers()
{
	return ((DM.NumPlayers + DM.NumBots) > wantedPlayers);
}

function Timer()
{
	if(!Level.Game.IsInState('MatchInProgress') || DM.bPlayersVsBots)
		return;
		
	if(NeedPlayers())
	{
		DM.AddBot();
	}
	else if(TooManyPlayers())
	{
		DM.KillBots(1);
	}
}
*/

defaultproperties
{
	bareMinimumPlayers=4
	countAlgorithm=1
	bInitialized=false
}
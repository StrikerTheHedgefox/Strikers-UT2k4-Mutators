//==============================================================================
// if EPIC would have fixed this, we would not even need this class
//==============================================================================
Class cDOM_MessageTextureClient extends MessageTextureClient
	placeable;

/* parameters for ScrollingMessage:

   %p - local player name
   %h - his/her for local player
   %lp - leading player's name
   %lf - leading player's frags
*/

simulated function Timer()
{
	local string Text;
	local PlayerReplicationInfo Leading, PRI;

	Text = ScrollingMessage;
	if(InStr(Text, "%lf") != -1 || InStr(Text, "%lp") != -1)
	{
		Leading = None;	// find the leading player
		ForEach AllActors(Class'PlayerReplicationInfo',PRI)
			if ( !PRI.bIsSpectator && (Leading==None || PRI.Score>Leading.Score) )
				Leading = PRI;

		if(Leading != None)
		{
			Text = Replace(Text, "%lp", Leading.PlayerName);
			Text = Replace(Text, "%lf", string(int(Leading.Score)));
			if ( Leading.bIsFemale )	//<New Code>
				Text = Replace(Text, "%h", HerMessage);
			else
				Text = Replace(Text, "%h", HisMessage);	//</new Code>
		}
		else
			Text = "";
	}
	if(bCaps)
		Text = Caps(Text);

	if(Text != OldText)
	{
		OldText = Text;
		MessageTexture.Revision++;
	}
}

defaultproperties
{
}

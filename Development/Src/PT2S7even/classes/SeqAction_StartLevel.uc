/*
 * Author: Michael Davidson
 * Last Edited: May 28, 2014
 * 
 * Purpose: create a kismet action to start levels, allows for setting timer and other level attributes (if we add any).
 */

class SeqAction_StartLevel extends SequenceAction;

var() float fTimeLimit;

event Activated()
{
	local NewtsCastle_GameType Game;

	Game = NewtsCastle_GameType(GetWorldInfo().Game);

	if (Game != none)
	{
		if (fTimeLimit > 0.0) {
			Game.fTimeLimit = fTimeLimit;
		} else {
			Game.fTimeLimit = 90.0;
		}

		Game.fCountDownTimer = fTimeLimit;
		Game.bTimeLimitReached = false;

		Game.bMouseActive = false;
		Game.bRunning = true;
	}
}

defaultproperties
{
	ObjName="Start Level"
	ObjCategory="NewtsCastle"

	VariableLinks.empty;
	VariableLinks(0) = (ExpectedType=class'SeqVar_Float', LinkDesc="Time Limit", PropertyName=fTimeLimit);

	fTimeLimit=180;

	bCallHandler = false;
}

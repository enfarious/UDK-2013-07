/*
 * Author: Michael Davidson
 * Last Edited: May 28, 2014
 * 
 * Purpose: create a kismet action to toggle the pause state of a level
 */

class SeqAction_PauseLevel extends SequenceAction;

Enum InputTypes 
{
	On,
	Off,
	Toggle
};

event Activated()
{
	local NewtsCastle_GameType Game;

	Game = NewtsCastle_GameType(GetWorldInfo().Game);

	if (InputLinks[On].bHasImpulse) {
		Game.bRunning = true;
	}
	if (InputLinks[Off].bHasImpulse) {
		Game.bRunning = false;
	}
	if (InputLinks[Toggle].bHasImpulse) {
		Game.bRunning = !Game.bRunning;
	}
}

defaultproperties
{
	ObjName="Toggle Pause"
	ObjCategory="NewtsCastle"

	InputLinks.empty;
	InputLinks(On)=(LinkDesc="On");
	InputLinks(Off)=(LinkDesc="Off");
	InputLinks(Toggle)=(LinkDesc="Toggle");

	bCallHandler = false;
}

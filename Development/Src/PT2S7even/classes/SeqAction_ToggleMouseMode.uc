/*
 * Author: Michael Davidson
 * Last Edited: Apr 20, 2014
 * 
 * Purpose: create a kismet action to toggle mouse mode on/off
 */

class SeqAction_ToggleMouseMode extends SequenceAction;

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
		Game.bMouseActive = true;
	}
	if (InputLinks[Off].bHasImpulse) {
		Game.bMouseActive = false;
	}
	if (InputLinks[Toggle].bHasImpulse) {
		Game.bMouseActive = !Game.bMouseActive;
	}
}

defaultproperties
{
	ObjName="ToggleMouseMode"
	ObjCategory="NewtsCastle"

	InputLinks.empty;
	InputLinks(On)=(LinkDesc="On");
	InputLinks(Off)=(LinkDesc="Off");
	InputLinks(Toggle)=(LinkDesc="Toggle");

}

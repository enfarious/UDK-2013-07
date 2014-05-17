/*
 * Author: Michael Davidson
 * Last Edited: May 17, 2014
 * 
 * Purpose: create a kismet action to adjust our game score
 */

class SeqAction_AdjustScore extends SequenceAction;

var() int ScoreValue;

event Activated()
{
	local NewtsCastle_GameType Game;

	Game = NewtsCastle_GameType(GetWorldInfo().Game);

	if (Game != none)
	{
		Game.nScore += ScoreValue;
	}
}

defaultproperties
{
	ObjName="Adjust Score"
	ObjCategory="NewtsCastle"

	VariableLinks.empty;
	VariableLinks(0) = (ExpectedType=class'SeqVar_Int', LinkDesc="AdjustAmnt", PropertyName=ScoreValue);

	ScoreValue=100;

	bCallHandler = false;
}

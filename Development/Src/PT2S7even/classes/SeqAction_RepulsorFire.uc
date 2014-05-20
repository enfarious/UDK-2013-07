/*
 * Author: Michael Davidson
 * Last Edited: May 20, 2014
 * 
 * Purpose: create a kismet action to actually fire the repulsor
 */

class SeqAction_RepulsorFire extends SequenceAction;

var() bool bHitPanel;
var() NewtsCastle_PlayerController Instigator;
var() Object Panel;

event Activated()
{
	local NewtsCastle_Pawn P;

	P = NewtsCastle_Pawn(Instigator.Pawn);
	P.Repulse(bHitPanel, kActor(Panel));
}

defaultproperties
{
	ObjName="Repulsor Fire Action"
	ObjCategory="NewtsCastle"

	VariableLinks.empty;
	VariableLinks(0) = (ExpectedType=class'SeqVar_Bool', LinkDesc="Hit Panel", PropertyName=bHitPanel);
	VariableLinks(1) = (ExpectedType=class'SeqVar_Object', LinkDesc="Player", PropertyName=Instigator);
	VariableLinks(2) = (ExpectedType=class'SeqVar_Object', LinkDesc="Target Panel", PropertyName=Panel);

	bCallHandler = false;
}

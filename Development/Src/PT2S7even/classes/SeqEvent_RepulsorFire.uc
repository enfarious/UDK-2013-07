/*
 * Author: Michael Davidson
 * Last Edited: May 20, 2014
 * 
 * Purpose: create a kismet action to start the repulsor firing event sequence
 */

class SeqEvent_RepulsorFire extends SequenceEvent;

event Activated()
{
}

defaultproperties
{
	ObjName="Repulsor Fire"
	ObjCategory="NewtsCastle"

	OutputLinks.empty;
	OutputLinks(0) = (LinkDesc="Fired");

	MaxTriggerCount = 0;
	bPlayerOnly = true;
	bAutoActivateOutputLinks = true;
}

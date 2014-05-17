/*
 * Author: Michael Davidson
 * Last Edited: May 17, 2014
 * 
 * Purpose: create a kismet event that triggers when the timer reaches 0
 */
class SeqEvent_OutOfTime extends SequenceEvent;

event Activated()
{
}

defaultproperties
{
	ObjName="Out of Time"
	ObjCategory="NewtsCastle"

	OutputLinks.empty;
	OutputLinks(0) = (LinkDesc="Out of Time");

	MaxTriggerCount = 0;
	bPlayerOnly = false;
	bAutoActivateOutputLinks = true;
}

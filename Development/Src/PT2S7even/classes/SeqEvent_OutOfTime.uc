/*
 * Author: Michael Davidson
 * Last Edited: Apr 20, 2014
 * 
 * Credit: Christopher Maxwell videos listed below
 * FSGDnBS_PT1_W2_04_Kismet_Event
 * FSGDnBS_PT1_W2_05_Kismet_Event_Outputlinks
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

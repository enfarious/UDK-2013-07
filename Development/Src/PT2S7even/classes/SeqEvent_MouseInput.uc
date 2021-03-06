/*
 * Author: Michael Davidson
 * Last Edited: May 17, 2014
 * 
 * Credit: http://udn.epicgames.com/Three/DevelopmentKitGemsCreatingAMouseInterface.html#Adding%20the%20mouse%20interaction%20interface
 * 
 * Purpose: This is a new game type extended from the packaged one in order to provide some different functionality
 */

class SeqEvent_MouseInput extends SequenceEvent;

var Vector HitLocation;
var Vector HitNormal;
var Vector MouseWorldOrigin;
var Vector MouseWorldDirection;

event Activated()
{
	local NewtsCastle_MouseInterfaceInteractionInterface MouseInteractionInterface;

	// Type cast the originator to ensure that it is a mouse interaction interface
	MouseInteractionInterface = NewtsCastle_MouseInterfaceInteractionInterface(Originator);

	if (MouseInteractionInterface != None)
	{
		// Get the appropriate values so we can push them out when the event is activated
		MouseWorldOrigin = MouseInteractionInterface.GetMouseWorldOrigin();
		MouseWorldDirection = MouseInteractionInterface.GetMouseWorldDirection();
		HitLocation = MouseInteractionInterface.GetHitLocation();
		HitNormal = MouseInteractionInterface.GetHitNormal();
	}
}

defaultproperties
{
	ObjName="Mouse Input"
	ObjCategory="Input"
   
	bPlayerOnly=false
	MaxTriggerCount=0

	OutputLinks(0)=(LinkDesc="Left Pressed")
	OutputLinks(1)=(LinkDesc="Left Released")
	OutputLinks(2)=(LinkDesc="Right Pressed")
	OutputLinks(3)=(LinkDesc="Right Released")
	OutputLinks(4)=(LinkDesc="Middle Pressed")
	OutputLinks(5)=(LinkDesc="Middle Released")
	OutputLinks(6)=(LinkDesc="Scroll Up")
	OutputLinks(7)=(LinkDesc="Scroll Down")
	OutputLinks(8)=(LinkDesc="Mouse Over")
	OutputLinks(9)=(LinkDesc="Mouse Out")

	VariableLinks(1)=(ExpectedType=class'SeqVar_Vector',LinkDesc="HitLocation",bWriteable=true,PropertyName=HitLocation)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Vector',LinkDesc="HitNormal",bWriteable=true,PropertyName=HitNormal)
	VariableLinks(3)=(ExpectedType=class'SeqVar_Vector',LinkDesc="MouseWorldOrigin",bWriteable=true,PropertyName=MouseWorldOrigin)
	VariableLinks(4)=(ExpectedType=class'SeqVar_Vector',LinkDesc="MouseWorldDirection",bWriteable=true,PropertyName=MouseWorldDirection)
}
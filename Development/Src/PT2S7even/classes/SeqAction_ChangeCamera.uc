/*
 * Author: Michael Davidson
 * Last Edited: Apr 20, 2014
 * 
 * Credit: Christopher Maxwell videos listed below
 * GDn3840-PT1_W2_Lecture.wmv
 * FSGDnBS_PT1_W2_02_Camera_Action_HUD
 * 
 * Purpose: create a kismet action to change camera view based on which input is used
 */

class SeqAction_ChangeCamera extends SequenceAction;

Enum CameraPerspective
{
   CAM_FirstPerson,
   CAM_ThirdPerson,
   CAM_TopDown,
   CAM_SideScroller,
   CAM_Isometric
};

var Actor m_ActorObj;

event Activated()
{
	if (InputLinks[CAM_FirstPerson].bHasImpulse) {
		ChangeCamera(0);
	}
	if (InputLinks[CAM_ThirdPerson].bHasImpulse) {
		ChangeCamera(1);
	}
	if (InputLinks[CAM_TopDown].bHasImpulse) {
		ChangeCamera(2);
	}
	if (InputLinks[CAM_SideScroller].bHasImpulse) {
		ChangeCamera(3);
	}
	if (InputLinks[CAM_Isometric].bHasImpulse) {
		ChangeCamera(4);
	}

}

function ChangeCamera(int CamType)
{
	local NewtsCastle_PlayerController rController;
	local NewtsCastle_Pawn rPawn;

	if (m_ActorObj != none)
	{
		rController = NewtsCastle_PlayerController(m_ActorObj);

		if (rController != none)
		{
			rPawn = NewtsCastle_Pawn(rController.Pawn);
		}
		
		if (rPawn == none)
		{
			rPawn = NewtsCastle_Pawn(m_ActorObj);
		}

		if (rPawn != none)
		{
			switch (CamType)
			{
			case 0:
				rPawn.CameraMode(CAM_FirstPerson);
				break;
			case 1:
				rPawn.CameraMode(CAM_ThirdPerson);
				break;
			case 2:
				rPawn.CameraMode(CAM_TopDown);
				break;
			case 3:
				rPawn.CameraMode(CAM_SideScroller);
				break;
			case 4:
				rPawn.CameraMode(CAM_Isometric);
				break;
			default:
				rPawn.CameraMode(CAM_FirstPerson);
				break;
			}
		}
	}
}

defaultproperties
{
	ObjName="ChangeCamera";
	ObjCategory="NewtsCastle";

	InputLinks.empty;
	// Each camera mode has a unique input
	InputLinks(CAM_FirstPerson)=(LinkDesc="FirstPerson");
	InputLinks(CAM_ThirdPerson)=(LinkDesc="ThirdPerson");
	InputLinks(CAM_TopDown)=(LinkDesc="TopDown");
	InputLinks(CAM_SideScroller)=(LinkDesc="SideScroller");
	InputLinks(CAM_Isometric)=(LinkDesc="Isometric");

	// This attaches to a player and needs one passed into it
	VariableLinks(0) = (ExpectedType=class'SeqVar_Object', LinkDesc="Player", PropertyName=m_ActorObj);

	m_ActorObj = none;

	// Player Object doesn't have a handler function for this action so we don't want it called
	bCallHandler = false;

	// Stop all outputs from always being on
	bAutoActivateOutputLinks = false;
}

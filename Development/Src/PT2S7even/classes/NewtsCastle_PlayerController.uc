/*
	* Author: Michael Davidson
	* Last Edited: Apr 20, 2014
	* 
	* Credit: Christopher Maxwell videos listed below
	* GDn3840-PT1_W2_Lecture.wmv
	* 
	* Credit: http://udn.epicgames.com/Three/CameraTechnicalGuide.html#Example%20All-In-One%20Camera
	* Credit: http://udn.epicgames.com/Three/DevelopmentKitGemsCreatingAMouseInterface.html#Unrealscript
	* 
	* Purpose: This is a new player controller type to utilize the new NewtsCastle_Pawn class
	*/

class NewtsCastle_PlayerController extends UDKPlayerController;

// Mouse event enum
enum EMouseEvent
{
	LeftMouseButton,
	RightMouseButton,
	MiddleMouseButton,
	ScrollWheelUp,
	ScrollWheelDown,
};

state PlayerWalking
{
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		local NewtsCastle_Pawn P;
		local Rotator tempRot;

		if( (Pawn != None) )
		{
			P = NewtsCastle_Pawn(Pawn);
			if(P != none)
			{
			if(P.CameraType == CAM_SideScroller)
			{
				Pawn.Acceleration.X = -1 * PlayerInput.aStrafe * DeltaTime * 100 * PlayerInput.MoveForwardSpeed;
				Pawn.Acceleration.Y = 0;
				Pawn.Acceleration.Z = 0;
               
				tempRot.Pitch = P.Rotation.Pitch;
				tempRot.Roll = 0;
				if(Normal(Pawn.Acceleration) Dot Vect(1,0,0) > 0)
				{
					tempRot.Yaw = 0;
					P.SetRotation(tempRot);
				}
				else if(Normal(Pawn.Acceleration) Dot Vect(1,0,0) < 0)
				{
					tempRot.Yaw = 32768;
					P.SetRotation(tempRot);
				}
			}
			else
			{

				if ( (DoubleClickMove == DCLICK_Active) && (Pawn.Physics == PHYS_Falling) )
					DoubleClickDir = DCLICK_Active;
				else if ( (DoubleClickMove != DCLICK_None) && (DoubleClickMove < DCLICK_Active) )
				{
					if ( UTPawn(Pawn).Dodge(DoubleClickMove) )
						DoubleClickDir = DCLICK_Active;
				}
               
				Pawn.Acceleration = newAccel;
			}

			if (Role == ROLE_Authority)
			{
				// Update ViewPitch for remote clients
				Pawn.SetRemoteViewPitch( Rotation.Pitch );
			}
			}

			CheckJumpOrDuck();
		}
	}
}

function UpdateRotation( float DeltaTime )
{
	local NewtsCastle_Pawn P;
	local Rotator   DeltaRot, newRotation, ViewRotation;

	P = NewtsCastle_Pawn(Pawn);

	if (NewtsCastle_GameType(WorldInfo.Game).bMouseActive) {
		return;
	}

	ViewRotation = Rotation;
	if (p != none && P.CameraType != CAM_SideScroller)
	{
		Pawn.SetDesiredRotation(ViewRotation);
	}

	// Calculate Delta to be applied on ViewRotation
	if( P != none && P.CameraType == CAM_SideScroller )
	{
		DeltaRot.Yaw = Pawn.Rotation.Yaw;
	}
	else
	{
		DeltaRot.Yaw = PlayerInput.aTurn;
	}
	DeltaRot.Pitch = PlayerInput.aLookUp; 

	ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
	SetRotation(ViewRotation);

	ViewShake( deltaTime );

	NewRotation = ViewRotation;
	NewRotation.Roll = Rotation.Roll;

	if (P != None && P.CameraType != CAM_SideScroller )
		Pawn.FaceRotation(NewRotation, deltatime);
}

// Handle mouse inputs
function HandleMouseInput(EMouseEvent MouseEvent, EInputEvent InputEvent)
{
	local NewtsCastle_HUD MouseInterfaceHUD;

	// Type cast to get our HUD
	MouseInterfaceHUD = NewtsCastle_HUD(myHUD);

	if (MouseInterfaceHUD != None)
	{
	// Detect what kind of input this is
	if (InputEvent == IE_Pressed)
	{
		// Handle pressed event
		switch (MouseEvent)
		{
		case LeftMouseButton:
			MouseInterfaceHUD.PendingLeftPressed = true;
			break;

		case RightMouseButton:
			MouseInterfaceHUD.PendingRightPressed = true;
			break;

		case MiddleMouseButton:
			MouseInterfaceHUD.PendingMiddlePressed = true;
			break;

		case ScrollWheelUp:
			MouseInterfaceHUD.PendingScrollUp = true;
			break;

		case ScrollWheelDown:
			MouseInterfaceHUD.PendingScrollDown = true;
			break;

		default:
			break;
		}
	}
	else if (InputEvent == IE_Released)
	{
		// Handle released event
		switch (MouseEvent)
		{
		case LeftMouseButton:
			MouseInterfaceHUD.PendingLeftReleased = true;
			break;

		case RightMouseButton:
			MouseInterfaceHUD.PendingRightReleased = true;
			break;

		case MiddleMouseButton:
			MouseInterfaceHUD.PendingMiddleReleased = true;
			break;

		default:
			break;
			}
		}
	}
}

// Hook used for the left and right mouse button when pressed
exec function StartFire(optional byte FireModeNum)
{
	HandleMouseInput((FireModeNum == 0) ? LeftMouseButton : RightMouseButton, IE_Pressed);
	Super.StartFire(FireModeNum);
}

// Hook used for the left and right mouse button when released
exec function StopFire(optional byte FireModeNum)
{
	HandleMouseInput((FireModeNum == 0) ? LeftMouseButton : RightMouseButton, IE_Released);
	Super.StopFire(FireModeNum);
}

// Called when the middle mouse button is pressed
exec function MiddleMousePressed()
{
	HandleMouseInput(MiddleMouseButton, IE_Pressed);
}

// Called when the middle mouse button is released
exec function MiddleMouseReleased()
{
	HandleMouseInput(MiddleMouseButton, IE_Released);
}

// Called when the middle mouse wheel is scrolled up
exec function MiddleMouseScrollUp()
{
	HandleMouseInput(ScrollWheelUp, IE_Pressed);
}

// Called when the middle mouse wheel is scrolled down
exec function MiddleMouseScrollDown()
{
	HandleMouseInput(ScrollWheelDown, IE_Pressed);
}

// Override this state because StartFire isn't called globally when in this function
auto state PlayerWaiting
{
	exec function StartFire(optional byte FireModeNum)
	{
		Global.StartFire(FireModeNum);
	}
}

defaultproperties
{
	InputClass=class'NewtsCastle_MouseInterfacePlayerInput';
}
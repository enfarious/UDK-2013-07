/*
	* Author: Michael Davidson
	* Last Edited: May 17, 2014
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
				Pawn.Acceleration.X = PlayerInput.aStrafe * DeltaTime * 100 * PlayerInput.MoveForwardSpeed;
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

			if (Role == ROLE_Authority)
			{
				// Update ViewPitch for remote clients
				Pawn.SetRemoteViewPitch( Rotation.Pitch );
			}
		}

		CheckJumpOrDuck();
	}
}

function UpdateRotation( float DeltaTime )
{
	local Rotator   DeltaRot, ViewRotation;

	if (NewtsCastle_GameType(WorldInfo.Game).bMouseActive) {
		return;
	}

	ViewRotation = Rotation;

	// Calculate Delta to be applied on ViewRotation
	DeltaRot.Yaw = Pawn.Rotation.Yaw;
	DeltaRot.Pitch = PlayerInput.aLookUp; 

	ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
	SetRotation(ViewRotation);
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
	local NewtsCastle_Pawn P;

	HandleMouseInput((FireModeNum == 0) ? LeftMouseButton : RightMouseButton, IE_Pressed);

	// Show REPULSOR charging effect ...

	if( (Pawn != None) )
	{
		P = NewtsCastle_Pawn(Pawn);
		if(P != none)
		{
			P.RepulsorCharging(true);
		}
	}

	Super.StartFire(FireModeNum);
}

// Hook used for the left and right mouse button when released
exec function StopFire(optional byte FireModeNum)
{
	local NewtsCastle_Pawn P;
	local float Force;

	HandleMouseInput((FireModeNum == 0) ? LeftMouseButton : RightMouseButton, IE_Released);

	// For testing lets just make this a silly amount of force in a couple directions
	// For reality it should be an amount of force based on angle of impact
	if( (Pawn != None) )
	{
		P = NewtsCastle_Pawn(Pawn);
		if(P != none)
		{
			Force = 10000; //P.RepulsorStrength;

			P.RepulsorCharging(false);

			Pawn.Acceleration.X = Force;
			Pawn.Acceleration.Y = 0;
			Pawn.Acceleration.Z = Force;
	

		}
	}

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
/*
 * Author: Michael Davidson
 * Last Edited: May 17, 2014
 * 
 * Credit: http://udn.epicgames.com/Three/DevelopmentKitGemsCreatingAMouseInterface.html#Unrealscript
 * 
 * Purpose: This is a new HUD type extended from the packaged HUD in order to provide some different functionality
 */

class NewtsCastle_HUD extends HUD;

// Member variables
var Font m_Font;
var MultiFont m_MultiFont;

var Texture2D m_HUDBG;
var Texture2D m_Reticle;

var const Texture2D CursorTexture; 
var const Color CursorColor;

// Pending left mouse button pressed event
var bool PendingLeftPressed;
// Pending left mouse button released event
var bool PendingLeftReleased;
// Pending right mouse button pressed event
var bool PendingRightPressed;
// Pending right mouse button released event
var bool PendingRightReleased;
// Pending middle mouse button pressed event
var bool PendingMiddlePressed;
// Pending middle mouse button released event
var bool PendingMiddleReleased;
// Pending mouse wheel scroll up event
var bool PendingScrollUp;
// Pending mouse wheel scroll down event
var bool PendingScrollDown;
// Cached mouse world origin
var Vector CachedMouseWorldOrigin;
// Cached mouse world direction
var Vector CachedMouseWorldDirection;
// Last mouse interaction interface
var NewtsCastle_MouseInterfaceInteractionInterface LastMouseInteractionInterface;

//
// HUD Rendering
//

// Draw the HUD on screen
function DrawHUD()
{
	Super.DrawHUD();

	DrawBackGround();
	DrawTimer();
	DrawScore();

	DrawReticle();

}

// Draw our HUD background
function DrawBackGround()
{
	Canvas.SetPos(0.0, 0.0);

	Canvas.DrawTile(m_HUDBG, 300, 200, 0.0, 0.0, m_HUDBG.SizeX, m_HUDBG.SizeY);
}

// Draw the games timer on screen
function DrawTimer()
{
	local float fTextSizeX, fTextSizeY, fTextScaleX, fTextScaleY;
	local NewtsCastle_GameType Game;

	Game = NewtsCastle_GameType(WorldInfo.Game);

	fTextScaleX = 2.0;
	fTextScaleY = 2.0;
	
	Canvas.Font = m_MultiFont;

	Canvas.SetPos(16.0, 8.0);
	if (Game.bTimeLimitReached) { // Ran out of time
		Canvas.SetDrawColor(255, 32, 0, 255);
	} else if (!Game.bTimeLimitReached && Game.fCountDownTimer < Game.fTimeLimit/4) { // Less than 25% time remaining
		Canvas.SetDrawColor(255, 255, 0, 255);
	} else { // More than 25% time remaining
		Canvas.SetDrawColor(32, 255, 32, 255);
	}

	Canvas.TextSize("Time: " @ Game.fCountDownTimer, fTextSizeX, fTextSizeY, fTextScaleX, fTextScaleY);
	Canvas.DrawText("Time: " @ Game.fCountDownTimer, false, fTextScaleX, fTextScaleY);
}

// Draw the game score on screen
function DrawScore()
{
	local float fTextSizeX, fTextSizeY, fTextScaleX, fTextScaleY;
	local NewtsCastle_GameType Game;

	Game = NewtsCastle_GameType(WorldInfo.Game);


	fTextScaleX = 2.0;
	fTextScaleY = 2.0;
	
	Canvas.Font = m_MultiFont;

	Canvas.SetPos(16.0, 32.0);
	Canvas.SetDrawColor(200, 200, 200, 255);

	Canvas.TextSize("Score: " @ Game.nScore, fTextSizeX, fTextSizeY, fTextScaleX, fTextScaleY);

	Canvas.DrawText("Score: " @ Game.nScore, false, fTextScaleX, fTextScaleY);

}

// Draw our Reticle on screen
function DrawReticle()
{
	local Vector MousePos, PawnScreenPos, ReticleSize, Direction;
	local Rotator ReticleRot;
	local float Angle;

	// local Color LineColor;

	local NewtsCastle_MouseInterfacePlayerInput Mouse;

	Mouse = NewtsCastle_MouseInterfacePlayerInput(PlayerOwner.PlayerInput);
	if (Mouse == none)
	{
		return;
	}

	PawnScreenPos = Canvas.Project(PlayerOwner.Pawn.Location);

	MousePos.X = Mouse.MousePosition.X;
	MousePos.Y = Mouse.MousePosition.Y;
	MousePos.Z = PawnScreenPos.Z;

	ReticleSize.X = 200;
	ReticleSize.Y = 200;
	ReticleSize.Z = 0;

	Direction = MousePos - PawnScreenPos;
	Angle = Atan2(Direction.X, Direction.Y);

	ReticleRot.Yaw = 16384 - ((Angle - Pi/2) * RadToUnrRot);
	ReticleRot.Roll = 0;
	ReticleRot.Pitch = 0;

	//LineColor.A = 127.0;
	//LineColor.R = 200.0;
	//LineColor.G = 10.0;
	//LineColor.B = 10.0;

	// Show a line from the mouse to the pawn if things seem wonky
	// Canvas.Draw2DLine(PawnScreenPos.X, PawnScreenPos.Y, MousePos.X, MousePos.Y, LineColor);
	
	Canvas.SetPos(PawnScreenPos.X - ReticleSize.X/2, PawnScreenPos.Y - ReticleSize.Y/2);
	Canvas.DrawRotatedTile(m_Reticle, ReticleRot, ReticleSize.X, ReticleSize.Y, 0, 0, m_Reticle.SizeX, m_Reticle.SizeY);
}

event PostRender()
{
	local NewtsCastle_MouseInterfacePlayerInput MouseInterfacePlayerInput;
	local NewtsCastle_MouseInterfaceInteractionInterface MouseInteractionInterface;
	local Vector HitLocation, HitNormal;

	Super.PostRender();

	// Ensure that we aren't using ScaleForm and that we have a valid cursor
	if (CursorTexture != None)
	{
	// Ensure that we have a valid PlayerOwner
	if (PlayerOwner != None)
	{
		// Cast to get the MouseInterfacePlayerInput
		MouseInterfacePlayerInput = NewtsCastle_MouseInterfacePlayerInput(PlayerOwner.PlayerInput);

		// If we're not using scale form and we have a valid cursor texture, render it
		if (MouseInterfacePlayerInput != None && NewtsCastle_GameType(WorldInfo.Game).bMouseActive)
		{
		// Set the canvas position to the mouse position
		Canvas.SetPos(MouseInterfacePlayerInput.MousePosition.X, MouseInterfacePlayerInput.MousePosition.Y);
		// Set the cursor color
		Canvas.DrawColor = CursorColor;
		// Draw the texture on the screen
		Canvas.DrawTile(CursorTexture, CursorTexture.SizeX, CursorTexture.SizeY, 0.f, 0.f, CursorTexture.SizeX, CursorTexture.SizeY,, true);
		}
	}
	}

	// Get the current mouse interaction interface
	MouseInteractionInterface = GetMouseActor(HitLocation, HitNormal);

	// Handle mouse over and mouse out
	// Did we previously had a mouse interaction interface?
	if (LastMouseInteractionInterface != None)
	{
	// If the last mouse interaction interface differs to the current mouse interaction
	if (LastMouseInteractionInterface != MouseInteractionInterface)
	{
		// Call the mouse out function
		LastMouseInteractionInterface.MouseOut(CachedMouseWorldOrigin, CachedMouseWorldDirection);
		// Assign the new mouse interaction interface
		LastMouseInteractionInterface = MouseInteractionInterface; 

		// If the last mouse interaction interface is not none
		if (LastMouseInteractionInterface != None)
		{
		// Call the mouse over function
		LastMouseInteractionInterface.MouseOver(CachedMouseWorldOrigin, CachedMouseWorldDirection); // Call mouse over
		}
	}
	}
	else if (MouseInteractionInterface != None)
	{
	// Assign the new mouse interaction interface
	LastMouseInteractionInterface = MouseInteractionInterface; 
	// Call the mouse over function
	LastMouseInteractionInterface.MouseOver(CachedMouseWorldOrigin, CachedMouseWorldDirection); 
	}

	if (LastMouseInteractionInterface != None)
	{
	// Handle left mouse button
	if (PendingLeftPressed)
	{
		if (PendingLeftReleased)
		{
		// This is a left click, so discard
		PendingLeftPressed = false;
		PendingLeftReleased = false;
		}
		else
		{
		// Left is pressed
		PendingLeftPressed = false;
		LastMouseInteractionInterface.MouseLeftPressed(CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
		}
	}
	else if (PendingLeftReleased)
	{
		// Left is released
		PendingLeftReleased = false;
		LastMouseInteractionInterface.MouseLeftReleased(CachedMouseWorldOrigin, CachedMouseWorldDirection);
	}

	// Handle right mouse button
	if (PendingRightPressed)
	{
		if (PendingRightReleased)
		{
		// This is a right click, so discard
		PendingRightPressed = false;
		PendingRightReleased = false;
		}
		else
		{
		// Right is pressed
		PendingRightPressed = false;
		LastMouseInteractionInterface.MouseRightPressed(CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
		}
	}
	else if (PendingRightReleased)
	{
		// Right is released
		PendingRightReleased = false;
		LastMouseInteractionInterface.MouseRightReleased(CachedMouseWorldOrigin, CachedMouseWorldDirection);
	}

	// Handle middle mouse button
	if (PendingMiddlePressed)
	{
		if (PendingMiddleReleased)
		{
		// This is a middle click, so discard 
		PendingMiddlePressed = false;
		PendingMiddleReleased = false;
		}
		else
		{
		// Middle is pressed
		PendingMiddlePressed = false;
		LastMouseInteractionInterface.MouseMiddlePressed(CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
		}
	}
	else if (PendingMiddleReleased)
	{
		PendingMiddleReleased = false;
		LastMouseInteractionInterface.MouseMiddleReleased(CachedMouseWorldOrigin, CachedMouseWorldDirection);
	}

	// Handle middle mouse button scroll up
	if (PendingScrollUp)
	{
		PendingScrollUp = false;
		LastMouseInteractionInterface.MouseScrollUp(CachedMouseWorldOrigin, CachedMouseWorldDirection);
	}

	// Handle middle mouse button scroll down
	if (PendingScrollDown)
	{
		PendingScrollDown = false;
		LastMouseInteractionInterface.MouseScrollDown(CachedMouseWorldOrigin, CachedMouseWorldDirection);
	}
	}
}

//
// Mouse Handling
//

function NewtsCastle_MouseInterfaceInteractionInterface GetMouseActor(optional out Vector HitLocation, optional out Vector HitNormal)
{
	local NewtsCastle_MouseInterfaceInteractionInterface MouseInteractionInterface;
	local NewtsCastle_MouseInterfacePlayerInput MouseInterfacePlayerInput;
	local Vector2D MousePosition;
	local Actor HitActor;

	// Ensure that we have a valid canvas and player owner
	if (Canvas == None || PlayerOwner == None)
	{
	return None;
	}

	// Type cast to get the new player input
	MouseInterfacePlayerInput = NewtsCastle_MouseInterfacePlayerInput(PlayerOwner.PlayerInput);

	// Ensure that the player input is valid
	if (MouseInterfacePlayerInput == None)
	{
	return None;
	}

	// We stored the mouse position as an IntPoint, but it's needed as a Vector2D
	MousePosition.X = MouseInterfacePlayerInput.MousePosition.X;
	MousePosition.Y = MouseInterfacePlayerInput.MousePosition.Y;
	// Deproject the mouse position and store it in the cached vectors
	Canvas.DeProject(MousePosition, CachedMouseWorldOrigin, CachedMouseWorldDirection);

	// Perform a trace actor interator. An interator is used so that we get the top most mouse interaction
	// interface. This covers cases when other traceable objects (such as static meshes) are above mouse
	// interaction interfaces.
	ForEach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, CachedMouseWorldOrigin + CachedMouseWorldDirection * 65536.f, CachedMouseWorldOrigin,,, TRACEFLAG_Bullet)
	{
	// Type cast to see if the HitActor implements that mouse interaction interface
	MouseInteractionInterface = NewtsCastle_MouseInterfaceInteractionInterface(HitActor);
	if (MouseInteractionInterface != None)
	{
		return MouseInteractionInterface;
	}
	}

	return None;
}

function Vector GetMouseWorldLocation()
{
	local NewtsCastle_MouseInterfacePlayerInput MouseInterfacePlayerInput;
	local Vector2D MousePosition;
	local Vector MouseWorldOrigin, MouseWorldDirection, HitLocation, HitNormal;

	// Ensure that we have a valid canvas and player owner
	if (Canvas == None || PlayerOwner == None)
	{
	return Vect(0, 0, 0);
	}

	// Type cast to get the new player input
	MouseInterfacePlayerInput = NewtsCastle_MouseInterfacePlayerInput(PlayerOwner.PlayerInput);

	// Ensure that the player input is valid
	if (MouseInterfacePlayerInput == None)
	{
	return Vect(0, 0, 0);
	}

	// We stored the mouse position as an IntPoint, but it's needed as a Vector2D
	MousePosition.X = MouseInterfacePlayerInput.MousePosition.X;
	MousePosition.Y = MouseInterfacePlayerInput.MousePosition.Y;
	// Deproject the mouse position and store it in the cached vectors
	Canvas.DeProject(MousePosition, MouseWorldOrigin, MouseWorldDirection);

	// Perform a trace to get the actual mouse world location.
	Trace(HitLocation, HitNormal, MouseWorldOrigin + MouseWorldDirection * 65536.f, MouseWorldOrigin , true,,, TRACEFLAG_Bullet);
	return HitLocation;
}

//
// Default Properties
//

DefaultProperties
{
	m_HUDBG = Texture2D'PT2S7even_Assets.Textures.T_HUD_BG';
	m_Font = MultiFont'UI_Fonts_Final.menus.Fonts_Positec';
	m_MultiFont = MultiFont'UI_Fonts_Final.HUD.MF_Small';

	m_Reticle = Texture2D'UI_HUD.HUD.UI_HUD_DamageDir';

	CursorColor=(R=255,G=255,B=255,A=255)
	CursorTexture=Texture2D'EngineResources.Cursors.Arrow'
}
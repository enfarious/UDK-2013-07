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
// Pending left mouse button pressed event
var bool PendingLeftPressed;
// Pending left mouse button released event
var bool PendingLeftReleased;
// Cached mouse world origin
var Vector CachedMouseWorldOrigin;
// Cached mouse world direction
var Vector CachedMouseWorldDirection;
// Last mouse interaction interface
var NewtsCastle_MouseInterfaceInteractionInterface LastMouseInteractionInterface;

// Distance Check okay?
var bool bDistanceOkay;
var Actor NCRepulsor;

var Font m_Font;
var MultiFont m_MultiFont;

var Texture2D m_HUDBG;
var Texture2D m_Reticle;

var const Texture2D CursorTexture; 
var const Color CursorColor;

var bool bMenuOpen;

var NC_MenuScene NCScene;

simulated event PostBeginPlay() {
	NewtsCastle_GameType(WorldInfo.Game).HUD = self;

	super.PostBeginPlay();
}

// Draw the HUD on screen
function DrawHUD()
{
	Super.DrawHUD();

	if (!bMenuOpen) {
		DrawBackGround();
		DrawTimer();
		DrawScore();
		DrawChargeLevel();
		DrawReticle();
	}

	//Mouse Trace Into World Debug
	//DrawDebugLine(CachedMouseWorldOrigin, CachedMouseWorldDirection * 65536.f, 200, 200, 200);
	TraceRepulseActor();
}

// Draw our HUD background
function DrawBackGround()
{
	Canvas.SetPos(0.0, 0.0);

	Canvas.DrawTile(m_HUDBG, 480, 240, 0.0, 0.0, m_HUDBG.SizeX, m_HUDBG.SizeY);
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

	Canvas.SetPos(16.0, 10.0);
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

	Canvas.SetPos(16.0, 30.0);
	Canvas.SetDrawColor(200, 200, 200, 255);

	Canvas.TextSize("Score: " @ Game.nScore, fTextSizeX, fTextSizeY, fTextScaleX, fTextScaleY);
	Canvas.DrawText("Score: " @ Game.nScore, false, fTextScaleX, fTextScaleY);

}


// Draw the repulsor charge level on screen
function DrawChargeLevel()
{
	local float fTextSizeX, fTextSizeY, fTextScaleX, fTextScaleY, fCharge;
	local NewtsCastle_GameType Game;

	Game = NewtsCastle_GameType(WorldInfo.Game);


	fTextScaleX = 2.0;
	fTextScaleY = 2.0;
	
	Canvas.Font = m_MultiFont;

	Canvas.SetPos(16.0, 50.0);

	if (Game.Pawn.RepulsorCooldown > 0.0) { // waiting on recharge
		fCharge = Game.Pawn.RepulsorCooldown;

		Canvas.SetDrawColor(200, 32, 32, 255);
		Canvas.TextSize("Repulsor Delay: " @ fCharge, fTextSizeX, fTextSizeY, fTextScaleX, fTextScaleY);
		Canvas.DrawText("Repulsor Delay: " @ fCharge, false, fTextScaleX, fTextScaleY);
	} else {	// charging
		fCharge = Game.Pawn.RepulsorStrength;

		Canvas.SetDrawColor(32, 200, 32, 255);
		Canvas.TextSize("Repulsor Strength: " @ fCharge, fTextSizeX, fTextSizeY, fTextScaleX, fTextScaleY);
		Canvas.DrawText("Repulsor Strength: " @ fCharge, false, fTextScaleX, fTextScaleY);
	}

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

	local int i;

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
	
			if(NCScene != none)
			{
				NCScene.RenderScene(Canvas, 0.1);

				for(i=0; i<NCScene.UIObjects.Length; i++)
				{
					NCScene.UIObjects[i].CheckBounds(MouseInterfacePlayerInput.MousePosition.X, MouseInterfacePlayerInput.MousePosition.Y);
					if(PendingLeftReleased == true)
					{
						NCScene.UIObjects[i].bClicked = true;
					}
					else
					{
						NCScene.UIObjects[i].bClicked = false;
					}
				}
				PendingLeftReleased = false;
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


function RenderMenu()
{
	if(NCScene == none)
	{
		NCScene = new () class'NC_MenuScene';
		NCScene.InitMenuScene(NewtsCastle_MouseInterfacePlayerInput(PlayerOwner.PlayerInput), SizeX, SizeY);
		`log("LoadingMenu");
	}
	else
	{
		
	}
}

function CheckViewPortAspectRatio()
{
	local Vector2D ViewportSize;
	local bool bIsWideScreen;
	local PlayerController PC;

	foreach LocalPlayerControllers(class'PlayerController', PC)
	{
		LocalPlayer(PC.Player).ViewportClient.GetViewportSize(ViewportSize);
		break;
	}

	bIsWideScreen = (ViewportSize.Y > 0.f) && (ViewportSize.X/ViewportSize.Y > 1.7);

	if(bIsWideScreen)
	{
		RatioX = SizeX / 1280.f;
		RatioY = SizeY / 720.f;
	}
}

// Trace if it is a Custom KActor or StaticActor and call TracedActor function
function TraceRepulseActor()
{
	local NewtsCastle_PlayerController PC;
	local NewtsCastle_Pawn P;
	local Vector TraceStart;
	local Vector TraceEnd;
	local NewtsCastle_MouseInterfacePlayerInput MouseInterfacePlayerInput;
	local Vector2D MousePosition;
	local Vector MouseWorldOrigin, MouseWorldDirection;
	local Actor HitActor;
	local Vector HitLocation;
	local Vector HitNormal;
	local float fDistanceCheck;
	local float fDistance;
	
	// Type cast to get the new player input
	MouseInterfacePlayerInput = NewtsCastle_MouseInterfacePlayerInput(PlayerOwner.PlayerInput);

	// We stored the mouse position as an IntPoint, but it's needed as a Vector2D
	MousePosition.X = MouseInterfacePlayerInput.MousePosition.X;
	MousePosition.Y = MouseInterfacePlayerInput.MousePosition.Y;
	// Deproject the mouse position and store it in the cached vectors
	Canvas.DeProject(MousePosition, MouseWorldOrigin, MouseWorldDirection);

	
	//Debug Trace
	PC = NewtsCastle_PlayerController ( PlayerOwner );
	if (PC != none)
	{
		P = NewtsCastle_Pawn ( PC.Pawn );
		if (P != none)
		{
			P.Mesh.GetSocketWorldLocationAndRotation('WeaponPoint', TraceStart);
			TraceEnd.X = MouseWorldDirection.X;
			TraceEnd.Y = 0;
			TraceEnd.Z = MouseWorldDirection.Z;
			//DrawDebugLine(TraceStart, TraceEnd * 65536.f, 255, 0, 0);

		}
	
	}

	// Perform a trace actor interator. An interator is used so that we get the top most mouse interaction
	// interface. This covers cases when other traceable objects (such as static meshes) are above mouse
	// interaction interfaces.
	// If such an actor is hit, call traced actor function
    
	NCRepulsor = none;
	
	ForEach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, TraceEnd * 65536.f, TraceStart, vect(10,10,10))
	{
	
	fDistanceCheck = VSize (P.Location - HitActor.Location);
	fDistance = 500.f;
	if (fDistanceCheck <= fDistance && fDistanceCheck > 0 && (HitActor.IsA('NewtsCastle_RepulsorKActorPlaceble') || HitActor.IsA('NewtsCastle_RepulsorActorStatic')))
		{
			`log("Kabuum Kactor");
			
			NCRepulsor = HitActor;
			TracedActor(HitLocation);
		}
	}

}


// If called it will return Distance, and if Distance is okay, it will return the object and boolean true.
function TracedActor( out Vector HitLocation )
{
	local float fMaxDistance;
	local float fCurrentDistance;
	local NewtsCastle_PlayerController PC;
	local NewtsCastle_Pawn P;


	fMaxDistance = 300.f;
	
	PC = NewtsCastle_PlayerController ( PlayerOwner );
	if ( PC != none )
	{
		P = NewtsCastle_Pawn ( PC.Pawn );
		if (P != none)
		{
			fCurrentDistance = VSize (P.Location - HitLocation);
		}
	}

	if (fMaxDistance >= fCurrentDistance)
	{
		
		`log("Distance Okay");
		bDistanceOkay = true;
	}


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

	bDistanceOkay = false;

}
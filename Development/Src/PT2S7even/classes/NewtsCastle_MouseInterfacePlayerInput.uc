/*
 * Author: Michael Davidson
 * Last Edited: May 17, 2014
 * 
 * Credit: http://udn.epicgames.com/Three/DevelopmentKitGemsCreatingAMouseInterface.html#Unrealscript
 * 
 * Purpose: This is a mouse input interface to allow us to use the mouse in game
 */

class NewtsCastle_MouseInterfacePlayerInput extends PlayerInput;

var NC_UIObject InteractiveObject;

var (Menus) array<NC_MenuScene> NC_MenuStack;
// Stored mouse position. Set to private write as we don't want other classes to modify it, but still allow other classes to access it.
var IntPoint MousePosition; 

event PlayerInput(float DeltaTime)
{
	// Handle mouse 
	// Ensure we have a valid HUD
	if (myHUD != None) 
	{
		// Add the aMouseX to the mouse position and clamp it within the viewport width
		MousePosition.X = Clamp(MousePosition.X + aMouseX, 0, myHUD.SizeX); 
		// Add the aMouseY to the mouse position and clamp it within the viewport height
		MousePosition.Y = Clamp(MousePosition.Y - aMouseY, 0, myHUD.SizeY); 
	}
	//`Log("MousePosition: " $MousePosition.X $", " $MousePosition.Y);
	Super.PlayerInput(DeltaTime);
}

DefaultProperties
{
}

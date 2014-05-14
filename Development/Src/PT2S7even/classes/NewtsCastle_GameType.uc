/*
 * Author: Michael Davidson
 * Last Edited: Apr 20, 2014
 * http://udn.epicgames.com/Three/GametypeTechnicalGuide.html
 * 
 * Purpose:	This is a new game type extended from the packaged one in order to provide some different functionality
 * 		specific to our implementation of Newt's Castle Mechanics.
 */

class NewtsCastle_GameType extends UDKGame;

var int nScore, nCameraMode, nDifficulty;
var float fPlayTimer, fCountDownTimer;
var bool bTimeLimitReached, bMouseActive;

// Update time, used by SetTimer to automatically call at a regular interval (1/10th of a second for now)
function Tick(float DeltaTime)
{
	fPlayTimer += DeltaTime;

	if (fCountDownTimer > 0) {
		fCountDownTimer -= DeltaTime;
	} else if (!bTimeLimitReached) {
		// The player has run out of time, fix the countdown timer at 0 and set TimeLimitReached
		bTimeLimitReached = true;
		fCountDownTimer = 0;
		// Finally trigger our custom Kismet event
		TriggerGlobalEventClass(class'SeqEvent_OutOfTime', self);
	}
}

DefaultProperties
{
	HUDType=class'NewtsCastle_HUD'
	DefaultPawnClass=class'NewtsCastle_Pawn'
	PlayerControllerClass=class'NewtsCastle_PlayerController'

	// Camera Settings
	nCameraMode = 1;

	// General Game Settings
	nDifficulty = 1;
	fPlayTimer = 0;
	fCountDownTimer = 30.0;
	bTimeLimitReached = false;
	nScore = 0;

	// Mouse Controller Settings
	bMouseActive = false;
}

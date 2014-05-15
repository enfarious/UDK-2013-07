/*
 * Author: Michael Davidson
 * Last Edited: May 15 2014
 * http://udn.epicgames.com/Three/GametypeTechnicalGuide.html
 * 
 * Purpose:	This is a new game type extended from the packaged one in order to provide some different functionality
 * 		specific to our implementation of Newt's Castle Mechanics.
 */

class NewtsCastle_GameType extends UDKGame;

var int nScore;
var float fCountDownTimer;
var bool bTimeLimitReached, bMouseActive;

// Update time, used by SetTimer to automatically call at a regular interval (1/10th of a second for now)
function Tick(float DeltaTime)
{
	if (fCountDownTimer > 0) {
		fCountDownTimer -= DeltaTime;
	} else if (!bTimeLimitReached) {
		// The player has run out of time, fix the countdown timer at 0 and set TimeLimitReached
		bTimeLimitReached = true;
		fCountDownTimer = 0;
		// Finally trigger our custom Kismet event
		TriggerGlobalEventClass(class'SeqEvent_OutOfTime', self);
	} else if (bTimeLimitReached) {
		fCountDownTimer += DeltaTime;
	}
}

DefaultProperties
{
	HUDType=class'NewtsCastle_HUD'
	DefaultPawnClass=class'NewtsCastle_Pawn'
	PlayerControllerClass=class'NewtsCastle_PlayerController'

	// General Game Settings
	fCountDownTimer = 180.0; // 3 minute countdown default
	bTimeLimitReached = false;
	nScore = 0;

	// Mouse Controller Settings
	bMouseActive = false;
}

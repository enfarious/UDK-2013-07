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
 * Purpose: This is a new Pawn type extended from the packaged Pawn in order to provide some different functionality
 */

class NewtsCastle_Pawn extends UDKPawn;

Enum CameraPerspective
{
   CAM_FirstPerson,
   CAM_ThirdPerson,
   CAM_TopDown,
   CAM_SideScroller,
   CAM_Isometric
};

var bool bFollowPlayerRotation;
var CameraPerspective CameraType;
var float CamOffsetDistance;
var int IsoCamAngle;

exec function CameraMode(CameraPerspective mode)
{
	local UTPlayerController UTPC;

	CameraType = mode;
	NewtsCastle_GameType(WorldInfo.Game).nCameraMode = mode;

	UTPC = UTPlayerController(Controller);
	if (UTPC != None)
	{
		if(CameraType != CAM_FirstPerson)
		{
			UTPC.SetBehindView(true);
			if(CameraType != CAM_ThirdPerson)
			{
				UTPC.bNoCrosshair = true;
			}
			else
			{
				UTPC.bNoCrosshair = false;
			}
		}
		else
		{
			UTPC.bNoCrosshair = false;

			UTPC.SetBehindView(false);
		}
		SetMeshVisibility(UTPC.bBehindView);
	}
}

exec function IsoAngle(int angle)
{
   IsoCamAngle = angle;
}

/* BecomeViewTarget
   Called by Camera when this actor becomes its ViewTarget */
simulated event BecomeViewTarget( PlayerController PC )
{
   local UTPlayerController UTPC;

   Super.BecomeViewTarget(PC);

   if (LocalPlayer(PC.Player) != None)
   {
      UTPC = UTPlayerController(PC);
      if (UTPC != None)
      {
         if(CameraType != CAM_FirstPerson)
         {
            UTPC.SetBehindView(true);
            if(CameraType != CAM_ThirdPerson)
            {
               UTPC.bNoCrosshair = true;
            }
            else
            {
               UTPC.bNoCrosshair = false;
            }
         }
         else
         {
            UTPC.bNoCrosshair = false;

            UTPC.SetBehindView(false);
         }
         SetMeshVisibility(UTPC.bBehindView);
      }
   }
}

/**
 *   Calculate camera view point, when viewing this pawn.
 *
 * @param   fDeltaTime   delta time seconds since last update
 * @param   out_CamLoc   Camera Location
 * @param   out_CamRot   Camera Rotation
 * @param   out_FOV      Field of View
 *
 * @return   true if Pawn should provide the camera point of view.
 */
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
   // Handle the fixed camera

   if (bFixedView)
   {
      out_CamLoc = FixedViewLoc;
      out_CamRot = FixedViewRot;
   }
   else
   {
      if ( CameraType == CAM_ThirdPerson )   // Handle BehindView
      {
         CalcThirdPersonCam(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
      }
      else if ( CameraType == CAM_TopDown )   // Handle BehindView
      {
         CalcTopDownCam(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
      }
      else if ( CameraType == CAM_SideScroller )   // Handle BehindView
      {
         CalcSideScrollerCam(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
      }
      else if ( CameraType == CAM_Isometric )   // Handle BehindView
      {
         CalcIsometricCam(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
      }
      else
      {
         // By default, we view through the Pawn's eyes..
         GetActorEyesViewPoint( out_CamLoc, out_CamRot );
      }

      if ( UTWeapon(Weapon) != none)
      {
         UTWeapon(Weapon).WeaponCalcCamera(fDeltaTime, out_CamLoc, out_CamRot);
      }
   }

   return true;
}

simulated function bool CalcTopDownCam( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
   out_CamLoc = Location;
   out_CamLoc.Z += CamOffsetDistance;

   if(!bFollowPlayerRotation)
   {
      out_CamRot.Pitch = -16384;
      out_CamRot.Yaw = 0;
      out_CamRot.Roll = 0;
   }
   else
   {
      out_CamRot.Pitch = -16384;
      out_CamRot.Yaw = Rotation.Yaw;
      out_CamRot.Roll = 0;
   }

   return true;
}

simulated function bool CalcSideScrollerCam( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
   out_CamLoc = Location;
   out_CamLoc.Y -= CamOffsetDistance;

   out_CamRot.Pitch = 0;
   out_CamRot.Yaw = 16384;
   out_CamRot.Roll = 0;

   return true;
}

simulated function bool CalcIsometricCam( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
   out_CamLoc = Location; 
   out_CamLoc.X -= Cos(IsoCamAngle * UnrRotToRad) * CamOffsetDistance;
   out_CamLoc.Z += Sin(IsoCamAngle * UnrRotToRad) * CamOffsetDistance;

   out_CamRot.Pitch = -1 * IsoCamAngle;   
   out_CamRot.Yaw = 0;
   out_CamRot.Roll = 0;

   return true;
}

/**
 * returns base Aim Rotation without any adjustment (no aim error, no autolock, no adhesion.. just clean initial aim rotation!)
 *
 * @return   base Aim rotation.
 */
simulated singular event Rotator GetBaseAimRotation()
{
   local vector   POVLoc;
   local rotator   POVRot, tempRot;

   if(CameraType == CAM_TopDown || CameraType == CAM_Isometric)
   {
      tempRot = Rotation;
      tempRot.Pitch = 0;
      SetRotation(tempRot);
      POVRot = Rotation;
      POVRot.Pitch = 0;
   }
   else if(CameraType == CAM_SideScroller)
   {
      POVRot = Rotation;
      if( (Rotation.Yaw % 65535 > 16384 && Rotation.Yaw % 65535 < 49560) ||
          (Rotation.Yaw % 65535 < -16384 && Rotation.Yaw % 65535 > -49560) )
      {
         POVRot.Yaw = 32768;
      }
      else
      {
         POVRot.Yaw = 0;
      }
         
      if( POVRot.Pitch == 0 )
      {
         POVRot.Pitch = RemoteViewPitch << 8;
      }
   }
   else
   {
      if( Controller != None && !InFreeCam() )
      {
         Controller.GetPlayerViewPoint(POVLoc, POVRot);
         return POVRot;
      }
      else
      {
         POVRot = Rotation;
         
         if( POVRot.Pitch == 0 )
         {
            POVRot.Pitch = RemoteViewPitch << 8;
         }
      }
   }

   return POVRot;
}


defaultproperties
{
   CameraType=CAM_FirstPerson;
   bFollowPlayerRotation = false;
   CamOffsetDistance=384.0
   IsoCamAngle=6420 //35.264 degrees
}
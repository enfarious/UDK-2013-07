/*
 * Author: Michael Davidson
 * Last Edited: Apr 20, 2014
 * 
 * Credit: http://udn.epicgames.com/Three/CameraTechnicalGuide.html#Example%20All-In-One%20Camera
 * Credit: http://udn.epicgames.com/Three/DevelopmentKitGemsCreatingAMouseInterface.html#Unrealscript
 * 
 * Purpose: This is a new Pawn type extended from the packaged Pawn in order to provide some different functionality
 */

class NewtsCastle_Pawn extends UDKPawn;

var float CamOffsetDistance; //Position on Y-axis to lock camera to

// sets whether or not the owner of this pawn can see it
simulated function SetMeshVisibility(bool bVisible)
{
	// Handle the main player mesh
	if (Mesh != None)
	{
		Mesh.SetOwnerNoSee(!bVisible);
	}
}

//override to make player mesh visible by default
simulated event BecomeViewTarget( PlayerController PC )
{
   local NewtsCastle_PlayerController NCPC;

   Super.BecomeViewTarget(PC);

   if (LocalPlayer(PC.Player) != None)
   {
      NCPC = NewtsCastle_PlayerController(PC);
      if (NCPC != None)
      {
         // make mesh visible
         SetMeshVisibility(true);
      }
   }
}

simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
   out_CamLoc = Location;
   out_CamLoc.Y -= CamOffsetDistance;

   out_CamRot.Pitch = 0;
   out_CamRot.Yaw = 16384;
   out_CamRot.Roll = 0;
   return true;
}

simulated singular event Rotator GetBaseAimRotation()
{
   local rotator   POVRot;

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

   return POVRot;
}   

defaultproperties
{
   CamOffsetDistance=384.0
}
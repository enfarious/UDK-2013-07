/*
 * Author: Michael Davidson
 * Last Edited: May 17, 2014
 * 
 * Credit: http://udn.epicgames.com/Three/CameraTechnicalGuide.html#Example%20All-In-One%20Camera
 * Credit: http://udn.epicgames.com/Three/DevelopmentKitGemsCreatingAMouseInterface.html#Unrealscript
 * 
 * Purpose: This is a new Pawn type extended from the packaged Pawn in order to provide some different functionality
 */

class NewtsCastle_Pawn extends UDKPawn;

var float CamOffsetDistance; //Position on Y-axis to lock camera to

var float RepulsorStrength; // Charge amount in repulsor
var float RepulsorMaxStrength; // Maximum charge in repulsor
var float RepulsorChargeSpeed; // How fast the repulsor will charge while button pressed

var float RepulsorCooldownTime; // How fast the repulsor can be fired again
var float RepulsorCooldown;

var float EmitterScale; // How large the repulsor effect should be while charging

var bool bCharging; // While the repulsor is charging

var	ParticleSystemComponent RepulsorComponent;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	NewtsCastle_GameType(WorldInfo.Game).Pawn = self;
}

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
   out_CamRot.Yaw = -16384;
   out_CamRot.Roll = 0;
   return true;
}

simulated singular event Rotator GetBaseAimRotation()
{
   local rotator POVRot;

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

//
// Used when repulsor fires, if a target is supplied the force will be applied to target
// if no target is supplied then force will be applied to the player pawn.
//
function Repulse(optional KActor Target)
{
	local float Force;
	local Vector MousePos, PawnScreenPos, Direction, ForceVector;
	local float Angle;

	local NewtsCastle_PlayerController P;
	local NewtsCastle_HUD MouseInterfaceHUD;
	local NewtsCastle_MouseInterfacePlayerInput Mouse;

	P = NewtsCastle_GameType(WorldInfo.Game).Controller;
	MouseInterfaceHUD = NewtsCastle_HUD(P.myHUD);

	Mouse = NewtsCastle_MouseInterfacePlayerInput(MouseInterfaceHUD.PlayerOwner.PlayerInput);
	if (Mouse == none)
	{
		return;
	}

// PawnScreenPos = MouseInterfaceHUD.Canvas.Project(P.Location);
	// Hax because canvas doesn't return valid values ...
	PawnScreenPos.X = P.myHUD.CenterX;
	PawnScreenPos.Y = P.myHUD.CenterY;

	MousePos.X = Mouse.MousePosition.X;
	MousePos.Y = Mouse.MousePosition.Y;
	MousePos.Z = PawnScreenPos.Z;

	Direction = PawnScreenPos - MousePos;
	Angle = Atan2(Direction.X, Direction.Y) ;

	// Calculate force vectors
	Force = RepulsorStrength;
	ForceVector.X = Force * ((0*Cos(Angle) - 1*Sin(Angle)));
	ForceVector.Y = 0.0;
	ForceVector.Z = Force * ((0*Sin(Angle) + 1*Cos(Angle)));

	`log("RepulsorStrength: " $RepulsorStrength);
	`log("Repulsor Force Vector: " $ForceVector.X $", " $ForceVector.Y $", " $ForceVector.Z);

	if (target != none) {
		if (target.IsA('NewtsCastle_RepulsorKActorPlaceble')) {
			target.ApplyImpulse(vect(10000,0,1230), Force*100, vect(0, 0, 0));

		} else if (MouseInterfaceHUD.NCRepulsor.IsA('NewtsCastle_RepulsorActorStatic')) {
			SetPhysics(PHYS_Falling);
			Velocity -= ForceVector;
		}
	} else if (MouseInterfaceHUD.NCRepulsor != none) {
		if (MouseInterfaceHUD.NCRepulsor.IsA('NewtsCastle_RepulsorKActorPlaceble')) {
			KActor(MouseInterfaceHUD.NCRepulsor).ApplyImpulse(vect(10000,0,1230), Force*100, vect(0, 0, 0));

		} else if (MouseInterfaceHUD.NCRepulsor.IsA('NewtsCastle_RepulsorActorStatic')) {
			SetPhysics(PHYS_Falling);
			Velocity -= ForceVector;
		}		
	}
	// Finally reset and stop the repulsor from charging further
	RepulsorCharge(false, ForceVector);
}

//
// Start and Stop the repulsor charging power
// When it is stopped (mouse button released) release charge in current direction
//
function RepulsorCharge(bool bStartCharging, optional Vector ForceVector)
{
	local ParticleSystem Repulsor;
	local ParticleSystem Repulse;

	if (bStartCharging == true)
	{

		Repulsor = ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball';

		RepulsorComponent = new(Outer) class'ParticleSystemComponent';
		if ( RepulsorComponent != none )
		{
			RepulsorComponent.SetDepthPriorityGroup(SDPG_Foreground);
			RepulsorComponent.SetTemplate(Repulsor);
			RepulsorComponent.SetTickGroup(TG_PostUpdateWork);
			RepulsorComponent.bUpdateComponentInTick = true;

			RepulsorComponent.SetScale ( 0.1f );
			Mesh.AttachComponentToSocket(RepulsorComponent, 'WeaponPoint');
		}
		
		RepulsorStrength += RepulsorChargeSpeed;
		bCharging = true;
	}
	else
	{
		Mesh.DetachComponent(RepulsorComponent);

		//Repulse = ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Altbeam_Gold';
		Repulse = ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Beam';
		RepulsorComponent = new(Outer) class'ParticleSystemComponent';
		if ( RepulsorComponent != none )
		{
			RepulsorComponent.SetScale (0.5 + RepulsorStrength / RepulsorMaxStrength);
			Mesh.AttachComponentToSocket(RepulsorComponent, 'DualWeaponPoint');
			RepulsorComponent.SetDepthPriorityGroup(SDPG_Foreground);
			RepulsorComponent.SetTemplate(Repulse);
			RepulsorComponent.SetTickGroup(TG_PostUpdateWork);
			RepulsorComponent.bUpdateComponentInTick = true;

	
			RepulsorComponent.SetVectorParameter('ShockBeamEnd', Location + ForceVector);
		}

		bCharging = false;
		EmitterScale = 0.0f;
		RepulsorStrength = 0.0f;
	}
}

function Tick(float DeltaTime)
{
	if (RepulsorCooldown > 0.0) {
		RepulsorCooldown -= DeltaTime;
	}

	if (RepulsorCooldown < 0.0) {
		RepulsorCooldown = 0.0;
	}

	if (bCharging == true) {
		if (RepulsorStrength < RepulsorMaxStrength)
		{
			RepulsorStrength += (RepulsorChargeSpeed - (RepulsorChargeSpeed * (1 / (RepulsorMaxStrength - RepulsorStrength)))) * DeltaTime;
		}
  
		EmitterScale = (RepulsorStrength / RepulsorMaxStrength) * 2;

		if (EmitterScale < 0.25f)
		{
			EmitterScale = 0.25f;
		} 
		else if (EmitterScale > 5.0f)
		{
			EmitterScale = 5.0f;
		}

		RepulsorComponent.SetScale(EmitterScale);
	}

 Super.Tick(DeltaTime);
}

defaultproperties
{
	CamOffsetDistance = -800.0;

	RepulsorStrength = 0;
	RepulsorChargeSpeed = 400;
	RepulsorMaxStrength = 900;

	RepulsorCooldown = 0.0;
	RepulsorCooldownTime = 1.5;

	EmitterScale = 0.1;

    Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bEnabled = true
    End Object
    Components.Add(MyLightEnvironment)

	Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=true;
		bCastDynamicShadow=true;
		bOwnerNoSee=false;
		LightEnvironment=MyLightEnvironment;
		Scale=1.65;
        CollideActors=true;
        BlockZeroExtent=true;

        BlockRigidBody=true;
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE)
		bBlockFootPlacement=false

		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics';
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_AimOffset';
		AnimSets(1)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale';
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human';
		SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA';
	End Object      

	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);

	// Physics=PHYS_RigidBody;
}
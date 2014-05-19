	/*
	* Author: Martin Egger
	* Last Edited: Mai 13, 2014
	* 
	* 
	* Credit: http://udn.epicgames.com/Three/DevelopmentKitGemsAddingSpritesMeshesParticleEffects.html

	* Purpose: Combining a StaticMesh with an Emitter.
	*/


class NewtsCastle_RepulsorReactiveActor extends KActor;

var() editconst const UDKParticleSystemComponent UDKParticleSystemComponent;


DefaultProperties
{
	//------------------------------------------------------------------------------------------------
	// Using the same as the parent StaticMeshActor, but make it able to add a particle.

	Begin Object Class=UDKParticleSystemComponent Name=UDKParticleSystemComponent0
		bAutoActivate=true
		Scale=3.0
		Translation=(X=0.0, Y=0, Z=24)
		SecondsBeforeInactive=1.0f
	End Object
	UDKParticleSystemComponent=UDKParticleSystemComponent0
	Components.Add(UDKParticleSystemComponent0)

	//------------------------------------------------------------------------------------------------
	// Adding a Sprite Component for Level Designers, to differantiate between normal Static Meshes and the repulsive reactive one
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Actor'
		Translation=(X=0.0, Y=0, Z=50)
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object

	Components.Add(Sprite)

}

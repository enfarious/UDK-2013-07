	/*
	* Author: Martin Egger
	* Last Edited: Mai 13, 2014
	* 
	* 
	* Credit: http://udn.epicgames.com/Three/DevelopmentKitGemsAddingSpritesMeshesParticleEffects.html

	* Purpose: Combining a StaticMesh with an Emitter.
	*/


class NewtsCastle_RepulsorReactiveActor extends StaticMeshActor
	placeable;

var() const EditInline Instanced array <PrimitiveComponent> PrimitiveComponents;

function PostBeginPlay()
{
  local int i;
  
  // Check the primitive components array to see if we need to add any components into the components array.
  if (PrimitiveComponents.Length > 0)
  {
    for (i = 0; i < PrimitiveComponents.Length; ++i)
    {
      if (PrimitiveComponents[i] != None)
      {
        AttachComponent(PrimitiveComponents[i]);
      }
    }
  }

  Super.PostBeginPlay();
}

DefaultProperties
{
	//------------------------------------------------------------------------------------------------
	// Using the same as the parent StaticMeshActor, but make it able to add a particle.

	Begin Object Class=ParticleSystemComponent Name=HighlightEffect
		bAutoActivate=true
		Scale=3.0
		Translation=(X=0.0, Y=0, Z=24)
		SecondsBeforeInactive=1.0f
	End Object
	Components.Add(HighlightEffect) 

	//------------------------------------------------------------------------------------------------
	// Adding a Sprite Component for Level Designers, to differantiate between normal Static Meshes and the repulsive reactive one
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Actor'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object

	Components.Add(Sprite)

}

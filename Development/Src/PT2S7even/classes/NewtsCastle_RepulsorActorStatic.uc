/*
	* Author: Alexis Barta
	* Last Edited: May 21, 2014
	* 
	* Credit: http://udn.epicgames.com/Three/ActorComponents.html
	* 
	* Purpose: This holds the static meshes for the repulsor actor that do not move.
	*/

class NewtsCastle_RepulsorActorStatic extends StaticMeshActor
	placeable;

DefaultProperties
{
	DrawScale3D=(X=1.0,Y=1.0,Z=.10)

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

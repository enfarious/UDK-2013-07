class NC_MenuScene extends Object;


var string MenuName;
var instanced array<NC_UIObject> UIObjects;

// font normality
var Font SceneCaptionFont;

// reference input owner
var NewtsCastle_MouseInterfacePlayerInput InputOwner;

// positions and sizing
var float Left;
var float Top;
var float Width;
var float Height;

var SoundCue UITouchSound;

var SoundCue UIUnTouchSound;

event InitMenuScene(NewtsCastle_MouseInterfacePlayerInput PlayerInput, int ScreenWidth, int ScreenHeight)
{
	local int i;

	SceneCaptionFont = MultiFont'UI_Fonts_Final.menus.Fonts_Positec';

	InputOwner = PlayerInput;

	for (i=0; i<UIObjects.Length; i++)
	{
		UIObjects[i].InitMenuObject(InputOwner, self, ScreenWidth, ScreenHeight);
	}
}

// Override this to change font size within the scene
function Font GetSceneFont()
{
	return class'Engine'.static.GetSmallFont();
}

function NC_UIObject FindMenuObject(string tag)
{
	local int i; 
	for (i=0; i<UIObjects.Length; i++)
	{
		if (Caps(UIObjects[i].Tag) == Caps(Tag))
		{
			return UIObjects[i];
		}
	}

	return none;
}

// render scene
function RenderScene(Canvas Canvas, float RenderDelta)
{
	local int i;

	for (i=0; i<UIObjects.Length; i++)
	{
		if (UIObjects[i] != none && !UIObjects[i].bIsHidden)
		{
			UIObjects[i].DrawButton(Canvas);
		}
	}
}

// Create objects which hold info to draw texture and position of button here
DefaultProperties
{
	Width=440
	Height=640
	Left=0.4
	Top=0.4

	Begin Object Class=NC_UIButton Name=Test
		Tag="Test"
		XT=100
		YL=100
		Width=140
		Height=24
		Images(0) = Texture2D'PT2S7even_Assets.Textures.Button_Normal'
		Images(1) = Texture2D'PT2S7even_Assets.Textures.Button_Hover'
		ImagesUVs(0) = (bCustomCoords=true, U=366, V=140, UL=260, VL=48)
		ImagesUVs(1) = (bCustomCoords=true, U=366, V=195, UL=260, VL=48)
		Caption = "Play"
		CaptionColor = (R=1.0, G=1.0, B=1.0, A=1.0)
	End Object
	UIObjects(0) = Test

	Begin Object Class=NC_UIButton Name=Test2
		Tag="Test2"
		XT=100
		YL=130
		Width=140
		Height=24

		Images(0) = Texture2D'PT2S7even_Assets.Textures.Button_Normal'
		Images(1) = Texture2D'PT2S7even_Assets.Textures.Button_Hover'
		ImagesUVs(0) = (bCustomCoords=true, U=366, V=140, UL=260, VL=48)
		ImagesUVs(1) = (bCustomCoords=true, U=366, V=195, UL=260, VL=48)
		Caption = "Level Select"
		CaptionColor = (R=1.0, G=1.0, B=1.0, A=1.0)
	End Object
	UIObjects(1)=Test2

	Begin Object Class=NC_UIButton Name=Test3
		Tag="Test3"
		XT=100
		YL=160
		Width=140
		Height=24
		
		Images(0) = Texture2D'PT2S7even_Assets.Textures.Button_Normal'
		Images(1) = Texture2D'PT2S7even_Assets.Textures.Button_Hover'
		ImagesUVs(0) = (bCustomCoords=true, U=366, V=140, UL=260, VL=48)
		ImagesUVs(1) = (bCustomCoords=true, U=366, V=195, UL=260, VL=48)
		Caption = "Status"
		CaptionColor = (R=1.0, G=1.0, B=1.0, A=1.0)
	End Object
	UIObjects(2)=Test3

}

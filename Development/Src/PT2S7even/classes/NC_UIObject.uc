class NC_UIObject extends Object dependson(Canvas);

// Left pos of object
var float XT;

// Top pos of object
var float YL;

// Width of object
var float Width;

// Height of object
var float Height;

struct UVCoords
{
	var bool bCustomCoords;

	// UV coords //
	var float U;
	var float V;
	var float UL;
	var float VL;
};

var transient bool bHasBeenInitialized;

// XOffset and YOffset shift position of widget within bounds//
var float XOffset;
var float YOffset;

// Widget tag
var string Tag;

var bool bIsActive;
var bool bIsHidden;
var bool bIsHighlighted;
var NewtsCastle_MouseInterfacePlayerInput InputOwner;
var float Opacity;
var NC_MenuScene OwnerScene;

var bool bClicked;

function InitMenuObject(NewtsCastle_MouseInterfacePlayerInput PlayerInput, NC_MenuScene Scene, int ScreenWidth, int ScreenHeight)
{
	InputOwner = PlayerInput;
	OwnerScene = Scene;

	if(!bHasBeenInitialized)
	{
		// Anything prior to drawing occurs here
	}

	bHasBeenInitialized=true;
}

function CheckBounds(float MousePositionX, float MousePositionY)
{
	local float FinalRangeX;
	local float FinalRangeY;

	if(bIsActive == true)
	{
		FinalRangeX = XT + Width;
		FinalRangeY = YL + Height;

		if(MousePositionX >= XT && MousePositionX <= FinalRangeX && MousePositionY >= YL && MousePositionY <= FinalRangeY)
		{
			bIsHighlighted = true; 
			if(bClicked == true)
			{
				`log("Clicked Button");
			}
		}
		else
		{
			bIsHighlighted = false;
		}
	}
}

function DrawButton(Canvas Canvas)
{
	`log(""@Tag$"IS being drawn");
}

DefaultProperties
{
	bClicked=false;
}

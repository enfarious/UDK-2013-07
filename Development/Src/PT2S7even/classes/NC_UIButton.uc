class NC_UIButton extends NC_UIObject;

var Texture2D Images[2];
var UVCoords ImagesUVs[2];
var LinearColor ImageColor;
var string Caption;
var LinearColor CaptionColor;

function InitMenuObject(NewtsCastle_MouseInterfacePlayerInput PlayerInput, NC_MenuScene Scene, int ScreenWidth, int ScreenHeight)
{
	local int i;

	super.InitMenuObject(PlayerInput, Scene, ScreenWidth, ScreenHeight);

	for (i=0; i<2; i++)
	{
		if(!ImagesUVs[i].bCustomCoords && Images[i] != none)
		{
			ImagesUVs[i].U = 0.0f;
			ImagesUVs[i].V = 0.0f;
			ImagesUVs[i].UL = Images[i].SizeX;
			ImagesUVs[i].VL = Images[i].SizeY;
		}
	}
}

function DrawButton(Canvas Canvas)
{
	local int Idx;
	local LinearColor DrawColor;

	//Swap texture when highlighted
	Idx = (bIsHighlighted) ? 1 : 0;
	DrawColor.R = 1.0;
	DrawColor.G = 1.0;
	DrawColor.B = 1.0;
	DrawColor.A = 1.0;
	Canvas.SetPos(XT, YL);
	Canvas.DrawTile(Images[Idx], Width, Height, ImagesUVs[Idx].U, ImagesUVs[Idx].V, ImagesUVs[Idx].UL, ImagesUVs[Idx].VL, DrawColor);

	RenderCaption(Canvas);
}

function RenderCaption(Canvas Canvas)
{
	local float X, Y, UL, VL;
	
	if(Caption != "")
	{
		Canvas.Font = OwnerScene.SceneCaptionFont;
		Canvas.TextSize(Caption, UL, VL);

		X = XT + (Width/2) - (UL/2);
		Y = YL + (Height/2) - (VL/2);

		Canvas.SetPos(X, Y);

		Canvas.DrawColor.R = byte(CaptionColor.R * 255.0);
		Canvas.DrawColor.G = byte(CaptionColor.G * 255.0);
		Canvas.DrawColor.B = byte(CaptionColor.B * 255.0);
		Canvas.DrawColor.A = byte(CaptionColor.A * 255.0);
	
		Canvas.DrawText(Caption);
	}
}

DefaultProperties
{

	ImageColor=(R=1.0, G=1.0, B=1.0, A=1.0)
	bIsActive=true
}

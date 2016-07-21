
'using mojo to make stuff.

#Import "<std>"
#Import "<mojo>"
#Import "<game2d>"

Using std..
Using mojo..
Using game2d

#Import "titlestate.monkey2"
#Import "playstate.monkey2"
#Import "player.monkey2"
#Import "bullet.monkey2"
#Import "rock.monkey2"
#Import "particle.monkey2"

#Import "assets/images/arcade.ttf"
#Import "assets/images/logo.png"
#Import "assets/images/rocks.png"

#Import "assets/sounds/bullet.wav"
#Import "assets/sounds/explosion.wav"
#Import "assets/sounds/stageup.wav"
#Import "assets/sounds/warp.wav"


Const TITLE_STATE:Int = 0
Const PLAY_STATE:Int = 1

'render layers
Const LAYER_ROCKS:Int = 0
Const LAYER_BULLETS:Int = 1
Const LAYER_PLAYER:Int = 2
Const LAYER_PARTICLES:Int = 3

' rock sizes, also image frames

Const SIZE_BIG:Int = 2
Const SIZE_MEDIUM:Int = 3
Const SIZE_SMALL:Int = 4

Global images:Image[]
Global hiscore:Int = 1206

Function Main()
	New AppInstance
	New Asteroids
	App.Run()
End Function


Class Asteroids Extends Game2d

	Method New()
		Super.New("Asteroids! - Monkey2 style",640,480,WindowFlags.Resizable)

		Layout = "letterbox"
		GameResolution = New Vec2i(320,240)
		Mouse.PointerVisible = False
		Style.BackgroundColor = New Color(0.05, 0.05, 0.15)
		Style.DefaultFont  = Font.Load( "asset::arcade.ttf", 10 )

		Debug = False

		SeedRnd( Millisecs())

		AddKeyboardControl("TURN LEFT", Key.Left)
		AddKeyboardControl("TURN RIGHT", Key.Right)
		AddKeyboardControl("THRUST", Key.Up)
		AddKeyboardControl("FIRE", Key.A)
		AddKeyboardControl("TELEPORT", Key.Down)

		AddJoystickAxisControl( "TURN", 0 )
		AddJoystickButtonControl( "FIRE", 1 )
		AddJoystickButtonControl( "THRUST", 2 )
		AddJoystickButtonControl( "TELEPORT", 3 )

		'set global image
		images = GrabAnimation(Image.Load("asset::rocks.png"),16,16,6)

		'add sounds, give easy to remember names.
		AddSound( "asset::bullet.wav", "bullet" )
		AddSound( "asset::explosion.wav", "explosion" )
		AddSound( "asset::stageup.wav", "levelup" )
		AddSound( "asset::warp.wav", "warp" )

		AddState( New TitleState, TITLE_STATE )
		AddState( New PlayState, PLAY_STATE )
		EnterTransition = New TransitionFadein
	End Method

End Class


Class TitleState Extends State

	Field logo:Image
	Field scale:InterPolated

	Method Enter:Void() Override
		EntityManager.GetInstance().RemoveAllEntities()
	End Method

	Method New()
		logo = Image.Load("asset::logo.png")
		DebugAssert( logo <> Null, "logo not loaded!!")
		logo.Handle = New Vec2f(0.5, 0.5)
		scale = New InterPolated(4.0,5.0,720)
	End Method

	Method Update:Void() Override
		scale.Update()

		If Keyboard.KeyHit( Key.Enter )
			GAME.EnterState( PLAY_STATE, New TransitionFadein, New TransitionFadeout )
		Endif
	End Method

	Method Render:Void(canvas:Canvas, tween:Double) Override

		canvas.DrawImage(logo, 160, 60, DegreesToRadians(10), scale.Value, scale.Value )

		canvas.Color = Color.White
		Game.DrawText(canvas, "Hi-Score: " + hiscore, 0, 1)
		Game.DrawText(canvas, "GAME2D EXAMPLE. C 2016 WDW", 0, Game.Height/2)

		canvas.Color = Color.Red
		Game.DrawText(canvas, "Press ENTER to Play!",0,Game.Height-30)

		canvas.Color = Color.Green
		Game.DrawText(canvas, "[ESCAPE] for main menu",0,Game.Height-15)
	End Method

End Class

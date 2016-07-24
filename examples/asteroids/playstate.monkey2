
Class PlayState Extends State

	Field rockCount:Int
	Field maxRocks:Int
	Field rockSplit:Int
	Field player:Player
	Field camera:CameraEntity

	Method Enter:Void() Override
		CreatePlayer()
		player.Reset()
		player.score = 0
		player.warps = 3
		player.dead = False
		player.lives = 3

		maxRocks = 2
		rockSplit = 2
		CreateRocks()

		local anchor:Entity = New Entity
		anchor.ResetPosition(GAME.Width/2, GAME.Height/2)
		AddEntity(anchor, LAYER_CAMERA)

		camera = New CameraEntity
		AddEntity( camera, LAYER_CAMERA)
		camera.Target = anchor
		camera.SnapToTarget()
	End Method

	Method Leave:Void() Override
		hiscore = Max(player.score, hiscore)
		player = Null
		RemoveAllEntities()
	End Method

	Method CreatePlayer:Void()
		player = New Player
		player.state = Self
		AddEntity( player, LAYER_PLAYER)
	End Method

	Method CreateRocks:Void()
		Local rock:Rock
		For Local i:= 0 Until maxRocks
			rock = New Rock
			rock.SetSize(SIZE_BIG)

			rock.ResetPosition( Rnd(10, GAME.Width-10), Rnd(10, GAME.Height-10))
			AddEntity( rock, LAYER_ROCKS)
			AddEntityToGroup( rock, "rocks" )
		Next
		rockCount = maxRocks
	End Method

	Method Update:Void() Override

		if rockCount = 0
			LevelUp()
			player.warps+=1
		endif

		If player.lives = 0 and Keyboard.KeyHit( Key.Enter )
			Game.EnterState( TITLE_STATE, New TransitionFadein, New TransitionFadeout )
		Endif

		If Keyboard.KeyHit( Key.E )
			Self.CreateExplosion( New Vec2f(Rnd(0,GAME.Width), Rnd(0,GAME.Height)),20)
		Endif
	End Method

	Method LevelUp:Void()
		maxRocks+=1
		maxRocks = Min(maxRocks, 11)
		CreateRocks()
		rockSplit+=1

		local channel:= PlaySound("levelup")
		channel.Volume = 1.0
	End Method

	Method CreateExplosion(position:Vec2f, amount:Int, speed:Float=0.9)
		Local particle:Particle
		For local i:Int = 1 to amount
			particle = New Particle
			particle.Position = position
			particle.Speed = Rnd(0.25,speed)
			particle.Angle = Rnd(360)
			AddEntity( particle, LAYER_PARTICLES )
			AddEntityToGroup( particle, "particles")
		Next

		camera.Shake(1)
		GAME.PlaySound("explosion")
	End Method

	Method Render:Void(canvas:Canvas, tween:Double) Override
		canvas.Color = Color.White
		Game.DrawText(canvas, "SCORE:" + player.score, 5, 1, False)
		Game.DrawText(canvas, "LIVES:" + player.lives, 0, 1)
		Game.DrawText(canvas, "WARPS:" + player.warps, GAME.Width-60, 1, False)

		If player.lives = 0
			canvas.Color = New Color(Rnd(0.5,1.0), Rnd(0.5,1.0), Rnd(0.5,1.0))
			Game.DrawText(canvas, "GAME OVER", 0, GAME.Height/2)
			canvas.Color = Color.Red
			Game.DrawText(canvas, "PRESS ENTER TO CONTINUE", 0, GAME.Height/2+20)
		Endif
	End Method

End Class

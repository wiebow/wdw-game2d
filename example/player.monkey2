
Class Player Extends ImageEntity

	Field lives:Int
	Field score:Int
	Field warps:Int

	Field dead:Bool
	Field deadPause:Int

	Field immune:Bool
	Field immuneDelay:Int
	Field immuneFlashDelay:Int = 7

	Field velocity:Vec2f
	Field acceleration:Vec2f

	Field state:PlayState

	Const THRUST:Float = 0.07

	Method New()
		Super.New(images)
		Self.Frame = 1
		Self.Color = Color.Red
		velocity = New Vec2f
		acceleration = New Vec2f
		Radius = 6
	End Method

	Method Reset:Void()
		velocity = New Vec2f(0,0)
		acceleration = New Vec2f(0,0)
		ResetPosition( GAME.GameResolution.X/2, GAME.GameResolution.Y/2 )

		'face up
		Rotation = 90

		immune = True
		immuneDelay = 100
	End Method

	Method Update:Void() Override

		if dead
			deadPause-=1
			if deadPause = 0
				if lives > 0
					dead = false
					Self.Reset()
					Self.Visible = True
				endif
			endif
			return
		endif

		if immune
			immuneDelay-=1
			If immuneDelay Mod immuneFlashDelay = 0
				self.Visible = not self.Visible
			endif

			if immuneDelay = 0
				immune = False
				self.Visible = True
			endif
		endif

		If X < -5 Then ResetPosition ( GAME.Width+5, Y )
		If X > GAME.Width+5 then ResetPosition( -5, Y )
		If Y < -5 Then ResetPosition( X, GAME.Height+5 )
		If Y > GAME.Height+5 Then ResetPosition( X, -5 )

		If KeyControlDown("TURN LEFT") Then Rotation+=3
		If KeyControlDown("TURN RIGHT") Then Rotation-=3
		If Rotation < 0 Then Rotation+= 360
		If Rotation > 360 Then Rotation-= 360

		'https://en.wikipedia.org/wiki/Radian
		If KeyControlDown("THRUST")
			Local radian:= DegreesToRadians(Rotation)
			acceleration.X =  Cos(radian) * THRUST
			acceleration.Y = -Sin(radian) * THRUST
		Endif

		If KeyControlHit("FIRE")
			Local b:= New Bullet(Rotation, New Vec2f(X,Y))
			b.state = state
			AddEntity(b , LAYER_BULLETS)
			AddEntityToGroup(b, "bullets")
			GAME.PlaySound("bullet")
		Endif

		If KeyControlHit("TELEPORT") and warps > 0
			warps-=1
			ResetPosition( Rnd(5, GAME.Width-5), Rnd(5, GAME.Height-5))
			velocity = New Vec2f
			acceleration = New Vec2f
			GAME.PlaySound("warp")
		Endif

		velocity += acceleration
		velocity *= 0.98
		Position+=velocity
		acceleration = New Vec2f

		If Not immune
			'rock collision

			local rocksList:= GetEntityGroup("rocks")
			For Local rock:= Eachin rocksList.Entities
				if Self.CheckCollision(rock)
					Self.dead = true
					Self.deadPause = 100
					Self.lives-=1
					Self.Visible = False
					state.CreateExplosion(Position, 15,0.7)
				endif
			Next

			'saucer bullet collision
			' todo

		Endif

	End Method

End Class

#Rem monkeydoc
#End
Class Bullet Extends ImageEntity

	Field life:int
	Field state:PlayState

	Const SPEED:Float = 4.5


	Method New(rotation:Float, position:Vec2f)
		Super.New(images)
		Self.Frame = 0
		Self.life = 45
		Self.Rotation = rotation
		Self.CollisionRadius = 4
		Self.ResetPosition(position.X, position.Y)
		Color = Color.White
	End Method

	Method Update:Void() Override
		life-=1
		if life = 0
			RemoveEntity(Self)
			Return
		endif

		Local radian:= DegreesToRadians(Rotation)
		X+=  Cos(radian) * SPEED
		Y+= -Sin(radian) * SPEED

		If X < -5 Then ResetPosition ( GAME.Width+5, Y )
		If X > GAME.Width+5 then ResetPosition( -5, Y )
		If Y < -5 Then ResetPosition( X, GAME.Height+5 )
		If Y > GAME.Height+5 Then ResetPosition( X, -5 )

		'collision with rock?
		Local group:= GetEntityGroup("rocks")
		For Local r := Eachin group.Entities
			Local r2 := Cast<Rock>(r)
			if Self.CheckCollision(r2)

				'get rid of bullet
				RemoveEntity(Self)
				state.CreateExplosion(r2.Position, 15,0.7)

				'add score to player
				state.player.score+= (r2.Frame+1)*10

				'see if we need to create new rocks
				'dont create rocks if this is a small rock
				If r2.Frame < 4
					Local newrock:Rock
					For Local i:= 1 To state.rockSplit
						newrock = New Rock

						newrock.SetSize(r2.Frame+1)
						newrock.ResetPosition(r2.X,r2.Y)

						AddEntity(newrock, LAYER_ROCKS)
						AddEntityToGroup(newrock, "rocks")
						state.rockCount+=1
					Next
				Endif

				'remove rock we've hit
				RemoveEntity(r)
				state.rockCount-=1

				' avoid scanning more rock collisions
				' for this bullet
				Return
			endif
		Next

	End Method

End Class
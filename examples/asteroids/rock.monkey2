
Class Rock Extends ImageEntity

	Method New()
		Super.New( images )
		Color = New Color( Rnd(0.5,1.0),Rnd(0.5,1.0),Rnd(0.5,1.0) )

		Rotation = Rnd(360)
		_rotationSpeed = Rnd(-0.7,0.7)
		_directionAngle = Rnd(360)
		Self.Scale = New Vec2f(2.0,2.0)
	End Method

	Method SetSize:Void(size:Int)
		Self.Frame = size
		Select size
			Case SIZE_BIG
				_moveSpeed = Rnd(0.1,0.2)
				CollisionRadius = 14
			Case SIZE_MEDIUM
				_moveSpeed = Rnd(0.3,0.4)
				CollisionRadius = 8
				_rotationSpeed = Rnd(-1,1)
			Case SIZE_SMALL
				_moveSpeed = Rnd(0.5,0.7)
				CollisionRadius = 4
				_rotationSpeed = Rnd(-2,2)
		End Select
	End Method

	Method Update:Void() Override
		Rotation+=_rotationSpeed

		Local radian:= DegreesToRadians(_directionAngle)
		X+= Cos(radian) * _moveSpeed
		Y+= -Sin(radian) * _moveSpeed

		If X < -16 Then ResetPosition ( GAME.Width+16, Y )
		If X > GAME.Width+16 then ResetPosition( -16, Y )
		If Y < -16 Then ResetPosition( X, GAME.Height+16 )
		If Y > GAME.Height+16 Then ResetPosition( X, -16 )
	End Method

	Private

	Field _moveSpeed:Float
	Field _rotationSpeed:Float
	Field _speed:Float
	Field _directionAngle:Float

End Class
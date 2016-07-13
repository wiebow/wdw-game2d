
Class Particle Extends ImageEntity

	Method New()
		Super.New(images)
		Self.Frame = 0
		Self._alphaChange = Rnd(0.01,0.02)
		Self._alpha = 1.0
	End Method

	Method Update:Void() Override

		Local radian:= DegreesToRadians(_angle)
		X+= Cos(radian) * _speed
		Y+= -Sin(radian) * _speed

		_speed *= 0.995

		If X < -16 Then ResetPosition ( GAME.Width+16, Y )
		If X > GAME.Width+16 then ResetPosition( -16, Y )
		If Y < -16 Then ResetPosition( X, GAME.Height+16 )
		If Y > GAME.Height+16 Then ResetPosition( X, -16 )

		Color = New Color( Rnd(0.5,1.0), Rnd(0.3,1.0), Rnd(0.3,1.0), _alpha )

		_alpha -= _alphaChange
		If _alpha <= 0.0 Then RemoveEntity(Self)
	End Method

	Property Speed:Float()
		Return _speed
	Setter( value:Float )
		_speed = value
	End

	Property Angle:Float()
		Return _angle
	Setter( value:Float )
		_angle = value
	End

	Private

	Field _speed:Float
	Field _angle:Float
	Field _alpha:Float
	Field _alphaChange:Float
End Class
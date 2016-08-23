
Namespace wdw.game2d

#Rem monkeydoc Entity that can be attached to an entity.

Camera entity MUST be added to renderlayer 0 to ensure that the made changes to the drawoffset apply to ALL entities in the entity manager.

#End
Class CameraEntity Extends Entity

	Method New:Void()
		_moveDrag = 0.06
		_targetVector = New Vec2f
		_shakeVector = New Vec2f
		_moveArea = Null
	End Method

	#Rem monkeydoc @hidden
	#End
	Method Update:Void() Override
		If _target = Null then return

		'determine vector to target
		_targetVector = _target.Position-Position

		'add drag
		_targetVector*=_moveDrag

		'move towards target
		Position+=_targetVector

		'shake?
		If _shaking
			Local rad:Float = DegreesToRadians(Rnd(360))
			_shakeVector = New Vec2f(Sin(rad), Cos(rad))
			_shakeVector *= _shakeRadius
			_shakeRadius *= 0.95
			If _shakeRadius < 0.001 Then _shaking = false
		Endif

		'constrain movement if required
		If _moveArea <> Null
			If X < _moveArea.Left
				Self.ResetX(_moveArea.Left)
			ElseIf X > _moveArea.Right
				Self.ResetX(_moveArea.Right)
			Endif

			If Y < _moveArea.Top
				Self.ResetY(_moveArea.Top)
			ElseIf Y > _moveArea.Bottom
				Self.ResetY(_moveArea.Bottom)
			Endif
		EndIf

		'update the viewport

		_viewport = New Rectf(  X - GAME.GameResolution.X/2,
								Y - GAME.GameResolution.Y/2,
								X + GAME.GameResolution.X/2,
								Y + GAME.GameResolution.Y/2)

	End Method

	#Rem monkeydoc @hidden
	#End
	Method Render:Void(canvas:Canvas) Override
		Local offsetX:Float = (GAME.Width / 2)-Self.RenderX  + _shakeVector.X
		Local offsetY:Float = (GAME.Height / 2)-Self.RenderY + _shakeVector.Y
		canvas.ClearMatrix()
		canvas.Translate( offsetX, offsetY)
	End Method

	#Rem monkeydoc Snaps camera to current target.
	#End
	Method SnapToTarget:Void()
		If _target = Null Then Return
		Self.ResetPosition(_target.X, _target.Y)
	End Method

	#Rem monkeydoc Returns true if the passed entity position is in the camera view.
	#End
	Method CanSee:Bool(entity:Entity)
		Return _viewport.Contains(entity.Position)
	End Method

	#Rem monkeydoc Shakes the camera, starting with passed radius.
	#End
	Method Shake:Void(radius:Float)
		_shaking = True
		_shakeRadius = radius
	End Method

	#Rem monkeydoc The camera target entity.

	The camera will follow this entity.

	#End
	Property Target:Entity()
		Return _target
	Setter( value:Entity )
		_target = value
	End

	#Rem monkeydoc Returns the camera view port.
	#End
	Property Viewport:Rectf()
		Return _viewport
	End

	#Rem monkeydoc The delay (drag) on the camera movement.

	Default is a drag of 0.06. Setting this to 0 will disable all camera movement.

	#End
	Property MoveDelay:Float()
		Return _moveDrag
	Setter( value:Float )
		value = Min(value,1.0)
		_moveDrag = value
	End

	#Rem monkeydoc The camera movement area bounds.

	Constrains movement of the camera. For example, setting this with a rect of -100,50,100,50 will create a camera that can move horizontal 200 pixels, but not vertical.

	By default there are no restictions to the movement.

	#End
	Property MoveArea:Rectf()
		Return _moveArea
	Setter( value:Rectf )
		_moveArea = value
	End

	Private

	Field _moveArea:Rectf

	Field _target:Entity
	Field _targetVector:Vec2f

	Field _moveDrag:Float

	Field _shaking:Bool
	Field _shakeRadius:Float
	Field _shakeVector:Vec2f

	'the camera sees this area of the world.
	Field _viewport:Rectf

End Class
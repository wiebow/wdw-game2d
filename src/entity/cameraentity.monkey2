
Namespace wdw.game2d

#Rem monkeydoc Entity that can be attached to an entity.

Camera entity MUST be added to renderlayer 0 to ensure that the made changes to the drawoffset apply to ALL entities in the entity manager.

#End
Class CameraEntity Extends Entity

	Method New:Void()
		_moveDrag = 0.06
		_viewPort = New Rectf
		_targetVector = New Vec2f
		_shakeVector = New Vec2f
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

	#Rem monkeydoc Returns true if the passed entity is in the camera view.
	#End
	Method CanSee:Bool(entity:Entity)
		Return _viewPort.Contains(entity.Position)
	End Method

	#Rem monkeydoc Shakes the camera, starting with passed radius.
	#End
	Method Shake:Void(radius:Float)
		_shaking = True
		_shakeRadius = radius
	End Method

	#Rem monkeydoc The camera target entity.
	#End
	Property Target:Entity()
		Return _target
	Setter( value:Entity )
		_target = value
	End

	#Rem monkeydoc @hidden The camera view port.

	Not supported yet.

	#End
	Property ViewPort:Rectf()
		Return _viewPort
	Setter( value:Rectf )
		_viewPort = value
	End

	#Rem monkeydoc The delay (drag) on the camera movement.
	#End
	Property MoveDelay:Float()
		Return _moveDrag
	Setter( value:Float )
		value = Min(value,1.0)
		_moveDrag = value
	End

	Private

	Field _target:Entity
	Field _targetVector:Vec2f

	Field _moveDrag:Float

	Field _shaking:Bool
	Field _shakeRadius:Float
	Field _shakeVector:Vec2f

	'the camera sees this area of the world
	Field _viewPort:Rectf

End Class
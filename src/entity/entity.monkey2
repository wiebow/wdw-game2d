
Namespace game2d

#Rem monkeydoc Game2D base entity class.
#End
Class Entity

	Method New()
		_position = New Vec2f
		_previousPosition = New Vec2f
		_renderPosition = New Vec2f
'		_groupName = ""
		_radius = 1.0
	End Method

	Property Position:Vec2f()
		Return _position
	Setter( value:Vec2f )
		_position = value
	End

	Property X:Float()
		Return _position.X
	Setter( value:Float)
		_position.X = value
	End

	Property Y:Float()
		Return _position.Y
	Setter( value:Float)
		_position.Y = value
	End

	Property RenderPosition:Vec2f()
		Return _renderPosition
	End

	Property RenderX:Float()
		Return _renderPosition.X
	End

	Property RenderY:Float()
		Return _renderPosition.Y
	End

	Property RenderLayer:EntityGroup()
		Return _renderLayer
	Setter( value:EntityGroup )
		_renderLayer = value
	End

	Property EntityGroup:EntityGroup()
		Return _group
	Setter( value:EntityGroup )
		_group = value
	End

'	Property GroupName:String()
'		Return _groupName
'	Setter( value:String )
'		_groupName = value
'	End

	Property Radius:Float()
		Return _radius
	Setter( value:Float )
		_radius = value
	End


	' this is called from the entity manager, in the render call.
	' hide this
	Method Interpolate(tween:Double)
		_renderPosition.X = _position.X * tween + _previousPosition.X * (1.0 - tween )
		_renderPosition.Y = _position.Y * tween + _previousPosition.Y * (1.0 - tween )
	End Method

	'called by entity manager during update loop
	Method UpdatePosition()
		_previousPosition.X = _position.X
		_previousPosition.Y = _position.Y
	End Method

	Method ResetPosition:Void(x:Float, y:Float)
		_position = New Vec2f(x,y)
		_previousPosition = New Vec2f(x,y)
		_renderPosition = New Vec2f(x,y)
	End Method


	'checks collision between this and passed entity.
	'using circle collision
	Method CheckCollision:Bool(entity:Entity)
		Local dx:Float = Self.X - entity.X
		Local dy:Float = Self.Y - entity.Y
		Local distance:Float = Sqrt( dx*dx + dy*dy )
		Local radii:Float = Self.Radius + entity.Radius
		If radii < distance Then Return False
		Return True
	End Method

	Method Update:Void() Virtual
	End Method

	Method Render:Void(canvas:Canvas) Virtual
	End Method

	Private

	Field _position:Vec2f
	Field _previousPosition:Vec2f
	Field _renderPosition:Vec2f
	Field _renderLayer:EntityGroup'RenderLayer
'	Field _groupName:String
	Field _group:EntityGroup

	'collision radius
	Field _radius:Float

End Class


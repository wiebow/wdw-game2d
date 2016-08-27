
Namespace wdw.game2d

#Rem monkeydoc Game2D base entity class.
#End
Class Entity

	Method New()
		_position = New Vec2f
		_previousPosition = New Vec2f
		_renderPosition = New Vec2f
		_radius = 1.0
	End Method

	#Rem monkeydoc Sets or returns the position of this entity.
	#End
	Property Position:Vec2f()
		Return _position
	Setter( value:Vec2f )
		_position = value
	End

	#Rem monkeydoc Sets or returns the X position of this entity.
	#End
	Property X:Float()
		Return _position.X
	Setter( value:Float)
		_position.X = value
	End

	#Rem monkeydoc Sets or returns the Y position of this entity.
	#End
	Property Y:Float()
		Return _position.Y
	Setter( value:Float)
		_position.Y = value
	End

	#Rem monkeydoc Returns the render (interpolated) position of this entity.
	#End
	Property RenderPosition:Vec2f()
		Return _renderPosition
	End

	#Rem monkeydoc Returns the render (interpolated) X position of this entity.
	#End
	Property RenderX:Float()
		Return _renderPosition.X
	End

	#Rem monkeydoc Returns the render (interpolated) Y position of this entity.
	#End
	Property RenderY:Float()
		Return _renderPosition.Y
	End

	#Rem monkeydoc Sets or returns the renderlayer of this entity.
	#End
	Property RenderLayer:EntityGroup()
		Return _renderLayer
	Setter( value:EntityGroup )
		_renderLayer = value
	End

	#Rem monkeydoc Sets or returns the entitygroup of this entity.
	#End
	Property EntityGroup:EntityGroup()
		Return _group
	Setter( value:EntityGroup )
		_group = value
	End

	#Rem monkeydoc Sets or returns the collision radius of this entity.
	#End
	Property Radius:Float()
		Return _radius
	Setter( value:Float )
		_radius = value
	End

	#Rem monkeydoc Returns or sets the entity collision flag.

	When set to False, the entity does not participate in collision checks.

	#End
	Property Collision:Bool()
		Return _collision
	Setter( value:Bool )
		_collision = value
	End

	#Rem monkeydoc @hidden Called by entity manager during render.
	#End
	Method Interpolate(tween:Double)
		_renderPosition.X = _position.X * tween + _previousPosition.X * (1.0 - tween )
		_renderPosition.Y = _position.Y * tween + _previousPosition.Y * (1.0 - tween )
	End Method

	#Rem monkeydoc @hidden Called by entity manager during update.
	#End
	Method UpdatePosition()
		_previousPosition.X = _position.X
		_previousPosition.Y = _position.Y
	End Method

	#Rem monkeydoc Resets the position of this entity to passed coordinates.

	Use this if you want to force the entity to a new position.

	@param x the new X position.

	@param y the new Y position.

	#End
	Method ResetPosition:Void(x:Float, y:Float)
		_position = New Vec2f(x,y)
		_previousPosition = New Vec2f(x,y)
		_renderPosition = New Vec2f(x,y)
	End Method

	#Rem monkeydoc Forces the entity to passed X position.
	#End
	Method ResetX:Void(newX:Float)
		_position.X = newX
		_previousPosition.X = newX
	End Method

	#Rem monkeydoc Forces the entity to passed Y position.
	#End
	Method ResetY:Void(newY:Float)
		_position.Y = newY
		_previousPosition.Y = newY
	End Method

	#Rem monkeydoc Checks collision between this and passed entity.

	Uses circular collision check. Update the radius of your entity if results are off.
	It can be overridden if you need to make your own collision code.

	@return Bool

	#End
	Method CheckCollision:Bool(entity:Entity) Virtual
		Local dx:Float = Self.X - entity.X
		Local dy:Float = Self.Y - entity.Y
		Local distance:Float = Self.Distance(entity)'Sqrt( dx*dx + dy*dy )
		Local radii:Float = Self.Radius + entity.Radius
		If radii < distance Then Return False
		Return True
	End Method

	#Rem monkeydoc Checks collision with all entities in passed group.

	The first entity collided with is returned.

	@param groupName Entity group to check collision with.

	@return Entity

	#End
	Method CollideWithGroup:Entity( groupName:String )
		Local group:= GetEntityGroup(groupName)
		If group = Null Then Return Null

		For local e:Entity = Eachin group.Entities
			If Self.CheckCollision(e) = True Then Return e
		Next
		Return Null
	End Method

	#Rem monkeydoc Returns the distance between entities.

	@param entity The entity to check distance with.

	@return Float

	#End
	Method Distance:Float(entity:Entity)
		Local dx:Float = Self.X - entity.X
		Local dy:Float = Self.Y - entity.Y
		Return Sqrt( dx*dx + dy*dy )
	End Method

	#Rem monkeydoc hook for entity update code.
	#End
	Method Update:Void() Virtual
	End Method

	#Rem monkeydoc hook for entity render code.
	#End
	Method Render:Void(canvas:Canvas) Virtual
	End Method

	#Rem monkeydoc @hidden

	Some debug display info

	#End
	Method RenderDebug:Void(canvas:Canvas)
		canvas.BlendMode = BlendMode.Alpha
		canvas.Scale(1.0, 1.0)
		canvas.Color = New Color(1.0,1.0,0.0, 0.2)
		canvas.DrawCircle( RenderX, RenderY, _radius )
	End Method


	Private

	Field _position:Vec2f
	Field _previousPosition:Vec2f
	Field _renderPosition:Vec2f
	Field _renderLayer:EntityGroup
	Field _group:EntityGroup

	' collision settings
	Field _collision:Bool
	Field _radius:Float
	Field _rect:Recti

End Class


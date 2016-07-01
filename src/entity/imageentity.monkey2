
Namespace game2d

#Rem monkeydoc Entity that holds and renders an image.
#End
Class ImageEntity Extends Entity

	#Rem monkeydoc Creates an entity with a single image frame.
	#End
	Method New(image:Image)
		_images = New Image[1]
		_images[0] = image
		Self.Initialize()
	End Method

	#Rem monkeydoc Creates an entity with an array of image frames.
	#End
	Method New(images:Image[])
		_images = images
		Self.Initialize()
	End Method

	Property Collision:Bool()
		Return _collision
	Setter( value:Bool )
		_collision = value
	End

	Property Visible:Bool()
		Return _visible
	Setter( value:Bool )
		_visible = value
	End

	Property Frame:Int()
		Return _frame
	Setter( value:Int )
		_frame = value
	End

	Property Scale:Vec2f()
		Return _scale
	Setter( value:Vec2f )
		_scale = value
	End

	Property Color:Color()
		Return _color
	Setter( value:Color )
		_color = value
	End

	Property Rotation:Float()
		Return _rotation
	Setter( value:Float )
		_rotation = value
	End

	Method Render:Void( canvas:Canvas) Override
		If Not _visible Then Return
		If Not _images Then Return

		'debug
'		canvas.DrawEllipse(X,Y, Radius, Radius)

		canvas.BlendMode = _blend
		canvas.Color = _color
		canvas.DrawImage(_images[_frame],
			             RenderX, RenderY,
			             DegreesToRadians(_rotation),
			             _scale.X, _scale.Y )
	End Method

	Private

	Method Initialize:Void()
		_scale = New Vec2f(1.0, 1.0)
		_frame = 0
		_rotation = 0

		_color = Color.White
		_blend = BlendMode.Alpha
		_visible = True
		_collision = True
		_collisionRect = New Rectf

		Self.Radius = _images[0].Width/2
	End Method

	Field _scale:Vec2f
	Field _images:Image[]
	Field _frame:Int
	Field _rotation:Float
	Field _color:Color
	Field _blend:BlendMode
	Field _visible:Bool
	Field _collision:Bool

	Field _collisionRect:Rectf

End Class
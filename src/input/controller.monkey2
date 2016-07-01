
Namespace game2d


#Rem monkeydoc Input controller.

For now, only supports keyboard.

#End
Class Controller

	Function GetInstance:Controller()
		If Not _instance Then Return New Controller
		Return _instance
	End Function

	Method New()
		DebugAssert( _instance = Null, "Unable to create another instance of singleton class: Controller")
		_instance = Self
		Self.Initialize()
	End Method

	Method Destroy()
		_instance = Null
	End Method

	Method Initialize()
		_keyControls = New StringMap<Key>
		_configuring = False
	End Method

	' scans the keyboard and assigns the HIT key to the active control.
	' which is passed on by its label.
	' returns true when a control has been reconfigured.
	Method ScanKeyboard:Bool(activeControlLabel:String)

		'301 is the last code in Enum Key
		For Local keyCode:Int = 8 To 301
			Local thiskey:Key = Keyboard.KeyCodeToKey(keyCode)
			If Keyboard.KeyHit( thiskey )

				'did we hit keys we cannot use?
				if thiskey = Key.Escape or thiskey = Key.F10 or thiskey = Key.F11 or thiskey = Key.F12 then Return False

				'set this scanned keycode to current control
				SetControl( activeControlLabel, thiskey )

				_configuringIndex+=1
				If _configuringIndex = _keyControls.Count()
					Configuring = False
				Endif
				Return True
			Endif
		Next
		Return False
	End Method

	Property Configuring:Bool()
		Return _configuring
	Setter( value:Bool )
		_configuring = value
		_configuringIndex = 0
	End

	Property ConfiguringIndex:Int()
		Return _configuringIndex
	Setter( value:Int )
		_configuringIndex = value
	End

	Property KeyControls:StringMap<Key>()
		Return _keyControls
	End

	Method AddControl:Void(name:String, key:Key)
		_keyControls.Set(name, key)
	End Method

	Method SetControl:Void(name:String, key:Key)
		_keyControls.Update( name, key )
	End Method

	Method ControlToString:String(name:String)
		Local k:Key = _keyControls.Get(name)
		DebugAssert( k = true, "could not find key with name: " + name)
		Return "" + name + ": " + Keyboard.KeyName(k)
	End Method

	Method KeyHit:Bool( name:String )
		Local k:Key = _keyControls.Get(name)
		DebugAssert( k = true, "could not find key with name: " + name)
		Return Keyboard.KeyHit( k )
	End Method

	Method KeyDown:Bool( name:String )
		Local k:Key = _keyControls.Get(name)
		DebugAssert( k = true, "could not find key with name: " + name)
		Return Keyboard.KeyDown( k )
	End Method


	Method Render:Void(canvas:Canvas, ypos:Int)
	End Method

	Private

	Global _instance:Controller

	Field _keyControls:StringMap<Key>
	Field _configuring:Bool
	Field _configuringIndex:Int

End Class


' -- helper functions ---------------------

Function AddKeyControl:Void( name:String, key:Key )
	Controller.GetInstance().AddControl(name, key)
End Function

Function KeyControlDown:Bool( name:string )
	Return Controller.GetInstance().KeyDown(name)
End Function

Function KeyControlHit:Bool( name:string )
	Return Controller.GetInstance().KeyHit(name)
End Function


Namespace game2d

Const DEVICE_KEYBOARD:Int = 0
Const DEVICE_JOYSTICK:Int = 1

Const TYPE_AXIS:Int = 0
Const TYPE_BUTTON:Int = 1
Const TYPE_HAT:Int = 2


#Rem monkeydoc Input controller

Maps game controls to input devices.

#End
Class Controller

	#Rem monkeydoc Returns the instance of this Controller manager.

	@return Controller.

	#End
	Function GetInstance:Controller()
		If Not _instance Then Return New Controller
		Return _instance
	End Function

	' do not use.
	Method New()
		DebugAssert( _instance = Null, "Unable to create another instance of singleton class: Controller")
		_instance = Self
		Self.Initialize()
	End Method

	#Rem monkeydoc Deletes this manager.
	#End
	Method Destroy()
		_instance = Null
	End Method

	' internal.
	Method Initialize()
		_keyControls = New StringMap<Key>
		_joyButtonControls = New StringMap<Int>
		_joyAxisControls = New StringMap<Int>
		_configuring = False
	End Method

	#Rem monkeydoc Sets and returns the configure flag.

	@return True or False

	#End
	Property Configuring:Bool()
		Return _configuring
	Setter( value:Bool )
		_configuring = value
		If _configuring Then SetupConfigure()
	End


	Method SetupConfigure:Void()
		Select _activeDevice
			Case DEVICE_KEYBOARD

				' add all keys (names) in the keycontrols list to an array

				_controlNames = New String[ _keyControls.Count() ]
				Local index:Int = 0
				For Local item:= EachIn _keyControls
		   			_controlNames[index] = item.Key
		   			index +=1
				Next

				_controlIndex = 0

			Case DEVICE_JOYSTICK

				' add all axis (names) in the axis list to an array

				_controlNames = New String[ _joyAxisControls.Count() ]
				Local index:Int = 0
				For Local item:= EachIn _joyAxisControls
		   			_controlNames[index] = item.Key
		   			index +=1
				Next

				_activeControlType = TYPE_AXIS
				_controlIndex = 0

		End Select
	End Method


	'returns true if control has been updated
	Method Update:Bool()
		Select _activeDevice
			Case DEVICE_KEYBOARD
				Return ScanKeyboard()
			Case DEVICE_JOYSTICK
				Select _activeControlType
					Case TYPE_AXIS
						Return ScanJoystickAxes()
					Case TYPE_BUTTON
						Return ScanJoystickButtons()
					Case TYPE_HAT

					Default

				End Select

		End Select
		Return False
	End Method


	' scans the keyboard and assigns the HIT key to the active control.
	' returns true if current control has been re-configured
	Method ScanKeyboard:Bool()

		'301 is the last code in Enum Key
		For Local keyCode:Int = 8 To 301
			Local thiskey:Key = Keyboard.KeyCodeToKey(keyCode)
			If Keyboard.KeyHit( thiskey )

				'did we hit keys we cannot use?
				if thiskey = Key.Escape or thiskey = Key.F10 or thiskey = Key.F11 or thiskey = Key.F12 then Return False

				'set this scanned key to current control name
				SetKeyControl( _controlNames[_controlIndex], thiskey )

				' have we done all the controls?
				_controlIndex+=1
				If _controlIndex = _controlNames.Length Then Configuring = False
				Return True
			Endif
		Next
		Return false
	End Method

	#Rem monkeydoc Returns all key controls in the manager.

	@return StringMap

	#End
	Property KeyControls:StringMap<Key>()
		Return _keyControls
	End

	#Rem monkeydoc Adds a new control with passed name to this manager.

	@param name Name of the control

	@param key Key to be mapped to the control.

	#End
	Method AddKeyControl:Void(name:String, key:Key)
		_keyControls.Set(name, key)
	End Method

	#Rem monkeydoc Updates a key control with a new value.

	@param name Name of the control existing control.

	@param key Key to be mapped to the control.

	#End
	Method SetKeyControl:Void(name:String, key:Key)
		_keyControls.Update( name, key )
	End Method

	#Rem monkeydoc Returns the key and mapped control as a string.

	@return String

	#End
	Method KeyControlToString:String(name:String)
		Local k:Key = _keyControls.Get(name)
		DebugAssert( k = true, "could not find key with name: " + name)
		Return "" + name + ": " + Keyboard.KeyName(k)
	End Method

	#Rem monkeydoc Returns true if the control with passed name is hit since the last update.

	@return Bool

	#End
	Method KeyHit:Bool( name:String )
		Local k:Key = _keyControls.Get(name)
		DebugAssert( k = true, "could not find key with name: " + name)
		Return Keyboard.KeyHit( k )
	End Method

	#Rem monkeydoc Returns true if the control with passed name is held down.

	@return Bool

	#End
	Method KeyDown:Bool( name:String )
		Local k:Key = _keyControls.Get(name)
		DebugAssert( k = true, "could not find key with name: " + name)
		Return Keyboard.KeyDown( k )
	End Method


' ***** joypad *****



	Property JoyButtonControls:StringMap<Int>()
		Return _joyButtonControls
	End

	Property JoyAxisControls:StringMap<Int>()
		Return _joyAxisControls
	End

	Property JoystickDevice:JoystickDevice()
		Return _joystickDevice
	End

	Property JoyStickLabel:String()
		Return _joystickDeviceMapping.Label
	End


	Method ScanJoystickAxes:Bool()

		' go through all the axes on the mapped joystick
		For Local axisIndex:Int = 0 Until _joystickDeviceMapping.AxisAmount

			' get axis value from joystick device
			Local value:Float = _joystickDevice.GetAxis(axisIndex)

			' see if the value of the axis has changed from its neutral value.
			Local triggered:Bool = False
			If _joystickDeviceMapping.AxisNeutral(axisIndex) = 0.0
				If value < -.5 or value > 0.5 then triggered = True
			Elseif _joystickDeviceMapping.AxisNeutral(axisIndex) = -1.0
'				Print( "value " + value )
				if value > 0.5 and value < 1.0 then triggered = True
			Endif

			If triggered

				'set current control to this axis index
				UpdateJoyAxisControl( _controlNames[_controlIndex], axisIndex )

				'go to next control
				_controlIndex+=1
				If _controlIndex = _controlNames.Length

					'or go to buttons when we're done with all axes controls
					' fill the control names array for buttons
					_controlNames = New String[ _joyButtonControls.Count() ]
					Local index:Int = 0
					For Local item:= EachIn _joyButtonControls
			   			_controlNames[index] = item.Key
			   			index +=1
					Next

					_activeControlType = TYPE_BUTTON
					_controlIndex = 0
				Endif
				Return True
			Endif
		Next
		Return False
	End Method


	Method ScanJoystickButtons:Bool()

		For Local buttonIndex:Int = 0 Until _joystickDeviceMapping.ButtonAmount
			If _joystickDevice.ButtonPressed(buttonIndex)

				'set current control to this axis index
				UpdateJoyButtonControl( _controlNames[_controlIndex], buttonIndex )

				'go to next button control
				_controlIndex+=1
				if _controlIndex = _controlNames.Length
					Configuring = False
					'go to hats if we're done with the buttons

				Endif
				Return True
			Endif
		Next
		Return False
	End Method


	#Rem monkeydoc @hidden

	Called when the menu is opened and when the game is started.
	It will check what the first joystick on the system is and create the appropriate mapping class.

	#End
	Method ScanForJoystick:Void()
		'we only use the first pad on the system
		_joystickDevice = JoystickDevice.Open( 0 )
		If Not _joystickDevice Return

		Select _joystickDevice.Name
			Case "Microsoft X-Box 360 pad"
				_joystickDeviceMapping = New Xbox360
			Case "Sony PLAYSTATION(R)3 Controller"
				_joystickDeviceMapping = New Ps3
			Case "Sony Computer Entertainment Wireless Controller"
				_joystickDeviceMapping = New Ps4
			Default
				_joystickDeviceMapping = New UnknownStick
		End Select
	End Method


	Method JoyAxisControlToString:String(name:String)
		Local index:= _joyAxisControls.Get(name)
		Return "" + name + ": " + _joystickDeviceMapping.AxisLabel(index)
	End Method


	Method JoyButtonControlToString:String(name:String)
		Local index:= _joyButtonControls.Get(name)
		Return "" + name + ": " + _joystickDeviceMapping.ButtonLabel(index)
	End Method


	Method JoyButtonHit:Bool( name:String )
		Local index:= _joyButtonControls.Get(name)
		Return _joystickDevice.ButtonPressed( index )
	End Method

	Method JoyButtonDown:Bool( name:String )
		Local index:= _joyButtonControls.Get(name)
		Return _joystickDevice.ButtonDown( index )
	End Method

	Method JoyAxisValue:Float( name:String )
		Local index:= _joyAxisControls.Get(name)
		Return _joystickDevice.GetAxis( index )
	End Method


	Method AddJoyButtonControl:Void(name:String, buttonindex:Int)
		_joyButtonControls.Set(name, buttonindex)
	End Method

	Method AddJoyAxisControl:Void(name:String, axisindex:Int)
		_joyAxisControls.Set(name, axisindex)
	End Method

	Method UpdateJoyButtonControl:Void(name:String, buttonindex:Int)
		_joyButtonControls.Update(name, buttonindex)
	End Method

	Method UpdateJoyAxisControl:Void(name:String, axisindex:Int)
		_joyAxisControls.Update(name, axisindex)
	End Method



	Property CurrentControlName:String()
		Return _controlNames[_controlIndex]
	End

	Property ActiveControlType:Int()
		Return _activeControlType
	End

	Property ActiveDevice:Int()
		Return _activeDevice
	Setter( value:Int )
		_activeDevice = value
	End


	Private

	Field _configuring:Bool
	Field _activeDevice:Int
	Field _activeControlType:Int

	' array of the control names that we are configuring
	Field _controlNames:String[]

	'to check if we have done all controls in the current map
	Field _controlIndex:Int

	' the plugged in joystick device
	Field _joystickDevice:JoystickDevice

	'mapping type. see joysticks.monkey2
	Field _joystickDeviceMapping:JoystickMapping

	Field _joyButtonControls:StringMap<Int>
	Field _joyAxisControls:StringMap<Int>
	Field _keyControls:StringMap<Key>

	Global _instance:Controller

End Class





' -- helper functions ---------------------


Function AddJoyButtonControl:Void( name:String, buttonindex:Int )
	Controller.GetInstance().AddJoyButtonControl(name, buttonindex)
End Function

Function AddJoyAxisControl:Void( name:String, axisindex:Int )
	Controller.GetInstance().AddJoyAxisControl(name, axisindex)
End Function

Function JoyButtonDown:Bool( name:String )
	Return Controller.GetInstance().JoyButtonDown(name)
End Function

Function JoyButtonHit:Bool( name:String )
	Return Controller.GetInstance().JoyButtonHit(name)
End Function

Function JoyAxisValue:Float( name:String )
	Return Controller.GetInstance().JoyAxisValue(name)
End Function


Function AddKeyControl:Void( name:String, key:Key )
	Controller.GetInstance().AddKeyControl(name, key)
End Function

Function KeyControlDown:Bool( name:string )
	Return Controller.GetInstance().KeyDown(name)
End Function

Function KeyControlHit:Bool( name:string )
	Return Controller.GetInstance().KeyHit(name)
End Function

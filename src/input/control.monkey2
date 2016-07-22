
namespace game2d

#Rem monkeydoc @hidden

A control is added to the inputmanager
A control maps to physical input. These can be keys, buttons, axes, hats

#End
Class Control Abstract

	'returns control label and mapped input string
	Method ToString:String() Virtual
		Return "blah"
	End Method

	Method ToJson:Int() Virtual
		Return 0
	End Method

	Property Label:String()
		Return _label
	End

	Property Programmed:Bool()
		Return _programmed
	Setter( value:Bool )
		_programmed = value
	End

 	Method Update:Bool()
 		If _programmed Then Return Program()
 		Return False
 	End Method

 	Method Program:Bool() Virtual
 		Return False
 	End Method

	Private

	Field _programmed:Bool
	Field _label:String

End Class


#Rem monkeydoc @hidden
#End
Class KeyboardControl Extends Control

	Method New( label:String, keycode:Int)'Key )
		_label = label
		_key = Cast<Key>(keycode)
	End Method

	Method ToString:String() Override
		Return "" + _label + ": " + Keyboard.KeyName(_key)
	End Method

	Method ToJson:Int() Override
		Return _key
	End Method

	Method Down:Bool()
		Return Keyboard.KeyDown( _key )
	End Method

	Method Hit:Bool()
		Return Keyboard.KeyHit( _key )
	End Method

 	'returns true if the re-programming was a success.
	Method Program:Bool() Override

		'301 is the last code in Enum Key
		For Local keyCode:Int = 8 To 301
			Local thiskey:Key = Keyboard.KeyCodeToKey(keyCode)
			If Keyboard.KeyHit( thiskey )

				'did we hit a key we cannot use?
				If thiskey = Key.Escape Or thiskey = Key.F10 Or thiskey = Key.F11 Or thiskey = Key.F12 Then Return False

				_key = thiskey
				_programmed = False
				Return True
			Endif
		Next
		Return False
	End Method


	'used by Configuration
	Property KeyCode:Key()
		Return _key
	End

	Private

	Field _key:Key

End Class


#Rem monkeydoc @hidden
#End
Class JoystickAxisControl Extends Control

	Method New( label:String, index:Int, targetValue:Float )
		_manager = InputManager.GetInstance()
		_joystickDevice = _manager.JoystickDevice
		_label = label
		_index = index
		_targetValue = targetValue
	End Method

	Method ToString:String() Override
		Return "" + _label + ": " + _manager.JoystickMapping.AxisLabel(_index)
 	End Method

	Method Value:Float()
		Return _joystickDevice.GetAxis(_index)
	End Method

	Method TargetValue:Float()
		Return _targetValue
	End Method

	Method NeutralValue:Float()
		Return _manager.JoystickMapping.AxisNeutral( _index )
	End Method

	Method ToJson:Int() Override
		Return _index
	End Method

	Method Program:Bool() Override

		' go through all the axes on the mapped joystick
		For Local axisIndex:Int = 0 Until _manager.JoystickMapping.AxisAmount

			' get axis value from joystick device
			Local value:Float = _joystickDevice.GetAxis(axisIndex)

			' see if the value of the axis has changed from its neutral value.
			Local triggered:Bool = False
			If _manager.JoystickMapping.AxisNeutral(axisIndex) = 0.0
				If value < -.5 Or value > 0.5 Then triggered = True
			Elseif _manager.JoystickMapping.AxisNeutral(axisIndex) = -1.0
				If value > 0.5 And value < 1.0 Then triggered = True
			Endif

			If triggered
				_index = axisIndex
				_targetValue = value
				_programmed = False
				Return True
			Endif
		Next
		Return False
	End Method

 	Private

 	Field _joystickDevice:JoystickDevice
 	Field _manager:InputManager
	Field _index:Int
	Field _targetValue:Float

End Class


Class JoystickButtonControl Extends Control

	Method New( label:String, index:Int )
		_index = index
		_label = label
		_manager = InputManager.GetInstance()
		_joystickDevice = _manager.JoystickDevice
	End Method

	Method ToString:String() Override
		Return "" + _label + ": " + _manager.JoystickMapping.ButtonLabel(_index)
 	End Method

	Method Down:Float()
		Return _joystickDevice.ButtonDown( _index )
	End Method

	Method Hit:Float()
		Return _joystickDevice.ButtonPressed( _index )
	End Method

	Method ToJson:Int() Override
		Return _index
	End Method

	Method Program:Bool() Override
		For Local buttonIndex:Int = 0 Until _manager.JoystickMapping.ButtonAmount
			If _joystickDevice.ButtonPressed(buttonIndex)
				_index = buttonIndex

				_programmed = False
				Return True
			Endif
		Next
		Return False
	End Method

 	Private

	Field _joystickDevice:JoystickDevice
	Field _manager:InputManager
	Field _index:Int

End Class


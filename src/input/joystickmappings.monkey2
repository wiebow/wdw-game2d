
namespace game2d

#Rem monkeydoc Base class for joypad mapping definitions.
#End
Class JoystickMapping Abstract

	Method AxisLabel:String( index:Int )
		Return _axes[index]
	End Method

	Method ButtonLabel:String( index:Int )
		Return _buttons[index]
	End Method

	Property Guid:String()
		Return _guid
	End

	Property Label:String()
		Return _label
	End

	Method ButtonIndex:Int( label:String)
		For Local index:= 0 to _buttons.Length
			If _buttons[index] = label Then Return index
		Next
		Return -1
	End Method

	Property ButtonAmount:Int()
		Return _buttons.Length
	End

	Property AxisAmount:Int()
		Return _axes.Length
	End

	Property HatAmount:Int()
		Return _hats
	End


	Method AxisNeutral:Float(index:Int)
		Return _axesNeutral[index]
	End Method

	Private

	Field _hats:Int
	Field _hat:String[]
	Field _buttons:String[]
	Field _axes:String[]
	Field _axesNeutral:Float[]

	Field _label:String
	Field _guid:String

End Class


#Rem monkeydoc Dummy stick to show when not recognized.
#End
Class UnknownStick Extends JoystickMapping

	Method New()
		_label = "Unknown Joystick"
	End Method

End Class

#Rem monkeydoc Xbox 360 wired controller mappings from button and axis names to Monkey2 ids.
#End
Class Xbox360 Extends JoystickMapping

	Method New()
		_label = "X-Box 360 Controller"
		_guid = "030000005e0400008e02000010010000"

		_buttons = New String[]("A",     		'0
								"B",			'1
								"X",			'2
								"Y",			'3
								"LB",			'4
								"RB",			'5
								"Back",			'6
								"Start",		'7
								"XBOX",			'8
								"Left Stick",	'9
								"Right Stick" )	'10

		_axes = New String[]( "Left Stick Horizontal",	'0
						      "Left Stick Vertical",	'1
							  "Left Trigger",			'2
							  "Right Stick Horizontal",	'3
							  "Right Stick Vertical",	'4
							  "Right Trigger" )			'5

		_axesNeutral = New Float[]( 0.0,0.0,-1.0,0.0,0.0,-1.0)

		_hats = 1
		_hat = New String[]( 	"", 	'0
								"UP", 	'1
								"RIGHT",'2
								"",		'3
								"DOWN",	'4
								"",		'5
								"",		'6
								"",		'7
								"LEFT") '8

	End Method

End Class


#Rem monkeydoc
#End
Class Ps3 Extends JoystickMapping

	Method New()
		_label = "PS3 Controller"
		_guid = "030000004c0500006802000011010000"

		_buttons = New String[]("Select",  		'0
								"Left Stick",	'1
								"Right Stick",	'2
								"Start",		'3
								"UP",			'4
								"RIGHT",		'5
								"DOWN",			'6
								"LEFT",			'7
								"L2 digital",	'8
								"R2 digital",	'9
								"L1",			'10
								"R1",			'11
								"Triangle",		'12
								"Circle",		'13
								"Cross",		'14
								"Square",		'15
								"PS",			'16
								"?1",			'17
								"?2")			'18

		_axes = New String[]( "Left Stick Horizontal",	'0
						      "Left Stick Vertical",	'1
							  "Right Stick Horizontal", '2
							  "Right Stick Vertical",	'3
							  "?1",						'4
							  "?2",						'5
							  "?3",						'6
							  "?4",						'7
							  "?5",						'8
							  "?6",						'9
							  "?7",						'10
							  "?8",						'11
							  "L2 analog",				'12
							  "R2 analog")				'13

		'this is weird. putting 12 and 13 to -1.0 does not work :/
		_axesNeutral = New Float[]( 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,-1.0,-1.0 )

		_hats = 0

	End Method

End Class

#Rem monkeydoc
#End
Class Ps4 Extends JoystickMapping

	Method New()
		_label = "PS4 Controller"
		_guid = "030000004c050000c405000011010000"

		_buttons = New String[]("Square",  		'0
								"Cross",		'1
								"Circle",		'2
								"Triangle",		'3
								"L1",			'4
								"R1",			'5
								"?1",			'6
								"?2",			'7
								"Share",		'8
								"Options",		'9
								"Right Stick",	'10
								"PS",			'11
								"Touch Pad")	'12

		_axes = New String[]( "Left Stick Horizontal",	'0
						      "Left Stick Vertical",	'1
							  "Right Stick Horizontal",	'2
							  "L2",						'3
							  "R2",						'4
							  "Right Stick Vertical")',	'5
'							  "?1",						'6
'							  "Pad Horizontal",			'7
'							  "Pad Vertical",			'8
'							  "Pad Touched")			'9

		_axesNeutral = New Float[]( 0.0,0.0,0.0,-1.0,-1.0,0.0)',-1.0,0.0,0.0,-1.0)

		_hats = 1
		_hat = New String[]( 	"", 	'0
								"UP", 	'1
								"RIGHT",'2
								"",		'3
								"DOWN",	'4
								"",		'5
								"",		'6
								"",		'7
								"LEFT") '8

	End Method

End Class


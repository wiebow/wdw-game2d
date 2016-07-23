
Namespace wdw.game2d

#Rem monkeydoc Menu class for Game2d.
#End
Class Menu


	#Rem monkeydoc Sets the menu to the main menu.
	#End
	Method Reset:Void()
		_mode = MODE_MAINMENU
	End Method


	#Rem monkeydoc Updates the menu system.

	According to mode, the input keys are scanned.

	#End
	Method Update:Void()

		Local input:= InputManager.GetInstance()

		If _mode = MODE_MAINMENU
			Select True
				Case Keyboard.KeyHit( Key.Escape )
					If _mode = MODE_MAINMENU Then GAME.Paused = False

'				Case Keyboard.KeyHit( Key.F10 )
'					_mode = MODE_AUDIO

				Case Keyboard.KeyHit( Key.F11 )
					GAME.Fullscreen = Not GAME.Fullscreen

				Case Keyboard.KeyHit( Key.F12 )
					_mode = MODE_CONTROLS
					input.DetectJoystick()

				Case Keyboard.KeyHit( Key.Q )
					GAME.RequestStop()

				Case Keyboard.KeyHit( Key.R )
					GAME.Paused = False
					GAME.OnRestartGame()
			End Select

		Elseif _mode = MODE_CONTROLS
			If input.Programming

				' update timer that flashes the active control when Programming
				_activeItemTimerCount-=1
				If _activeItemTimerCount<0
					_activeItemTimerCount = _activeItemTimerDelay
					_activeHighlight= Not _activeHighlight
				Endif

				If Keyboard.KeyHit( Key.Escape )
					input.Programming = False
				Else
					if input.Update() = true
						_activeItemTimerCount = _activeItemTimerDelay
						_activeHighlight = True
					endif
				Endif

			Else
				'not programming

				Select True
					Case Keyboard.KeyHit( Key.Escape )
						_mode = MODE_MAINMENU

					Case Keyboard.KeyHit( Key.D )
						input.ActiveDevice = Not input.ActiveDevice

					Case Keyboard.KeyHit( Key.F12)
						input.Programming = True
						input.Update()

						'restart line flash timer, start on
						_activeItemTimerCount = _activeItemTimerDelay
						_activeHighlight = True
				End Select
			Endif

		Elseif _mode = MODE_AUDIO
			Select True
				Case Keyboard.KeyHit( Key.Escape )
					_mode = MODE_MAINMENU

			End Select
		Endif

	End Method


	#Rem monkeydoc @hidden
	#End
	Method Render:Void(canvas:Canvas)

		Local matrix:= canvas.Matrix
		canvas.ClearMatrix()

		Local ypos:Int
		Select _mode
			Case MODE_MAINMENU 	DrawMainMenu(canvas)
			Case MODE_AUDIO		DrawAudioMenu(canvas)
			Case MODE_CONTROLS 	DrawControlsMenu(canvas)
		End Select

		canvas.Matrix = matrix

	End Method


	#Rem monkeydoc @hidden
	#End
	Method DrawMainMenu:Void(canvas:Canvas)

		Local fontHeight:Int = GAME.Style.DefaultFont.Height
		Local ypos:Int = DrawMenuBorder( canvas, 7)

		canvas.Alpha = 1.0
		canvas.Color = Color.Cyan
		GAME.DrawText(canvas, "Game Menu",0,ypos)

		ypos+=fontHeight+4
		canvas.Color = Color.White
		GAME.DrawText(canvas, "[R] Restart To Title Screen",0,ypos)
		ypos+=fontHeight
		GAME.DrawText(canvas, "[Q] Quit To Desktop",0,ypos)
		ypos+=fontHeight
'		GAME.DrawText(canvas, "[F10] View/Set Audiodriver",0,ypos)
'		ypos+=fontHeight

		GAME.DrawText(canvas, "[F11] Fullscreen/Windowed",0,ypos)
		ypos+=fontHeight
		GAME.DrawText(canvas, "[F12] View/Configure Controls",0,ypos)

		ypos+=fontHeight+4
		canvas.Color = Color.Green
		GAME.DrawText(canvas, "[ESCAPE] Continue Game",0,ypos)
	End Method

	' to do.
	Method DrawAudioMenu:Void( canvas:Canvas )
		Local fontHeight:Int = GAME.Style.DefaultFont.Height
		Local ypos:Int = DrawMenuBorder( canvas, 8)

		canvas.Alpha = 1.0
		canvas.Color = Color.Cyan
		GAME.DrawText(canvas, "Audio",0,ypos)
	End Method

	Method DrawControlsMenu:Void(canvas:Canvas)
		Select InputManager.GetInstance().ActiveDevice
			Case DEVICE_KEYBOARD	DrawKeyboardControls(canvas)
			Case DEVICE_JOYSTICK	DrawJoystickControls(canvas)
		End Select
	End Method


	#Rem monkeydoc @hidden
	#End
	Method DrawKeyboardControls:Void(canvas:Canvas)

		Local input:= InputManager.GetInstance()
		Local fontHeight:Int = GAME.Style.DefaultFont.Height

  		' determine amount of lines needed
		Local lines:Int = input.KeyboardControls.Count() + 4

		' and draw the menu border
		Local ypos:Int = DrawMenuBorder( canvas, lines)

		canvas.Color = Color.Cyan
		If input.Programming
			GAME.DrawText(canvas, "Configure Key Controls", 0, ypos)
		Else
			GAME.DrawText(canvas, "Key Controls", 0, ypos)
		Endif

		' now draw the key controls list

		ypos+=fontHeight+4
		For Local control:=EachIn input.KeyboardControls.Values
		   	canvas.Color = Color.White

			' select the correct color when programming this control
		   	If input.Programming and control.Programmed
		   		If _activeHighlight Then canvas.Color = Color.Red
			Endif

			GAME.DrawText(canvas, control.ToString(), 0, ypos)
			ypos+=fontHeight
		Next

		' draw footer or reconfigure message

		ypos+=4
		canvas.Color = Color.Green
		If input.Programming
			GAME.DrawText(canvas, "Select new key for '" + input.ProgrammedControl.Label + "'", 0, ypos)
			ypos+=fontHeight
			GAME.DrawText(canvas, "[ESCAPE] Cancel Configuration", 0, ypos)
		Else
			GAME.DrawText(canvas, "[D] Change Device to Joystick",0,ypos)
			ypos+=fontHeight
			GAME.DrawText(canvas, "[ESCAPE] Back  [F12] Configure", 0, ypos)
		Endif

	End Method


	#Rem monkeydoc @hidden
	#End
	Method DrawJoystickControls( canvas:Canvas )
		Local input:InputManager = InputManager.GetInstance()
		Local fontHeight:Int = GAME.Style.DefaultFont.Height

		' determine amount of lines needed
		' adjust when no stick is detetced

		Local lines:Int = input.JoystickControls.Count()+5
'		lines += input.JoystickButtonControls.Count() + 5
		If input.JoystickDevice = Null then lines = 5

		Local ypos:Int = DrawMenuBorder( canvas, lines)

		' draw menu title

		canvas.Color = Color.Cyan
		If input.Programming
			GAME.DrawText(canvas, "Configure Joystick Controls", 0, ypos)
		Else
			GAME.DrawText(canvas, "Joystick Controls", 0, ypos)
		Endif

		' and quit when no stick is detected

		If input.JoystickDevice = Null
			ypos+=fontHeight+4
			canvas.Color = Color.White
			GAME.DrawText(canvas, "No Joystick detected!",0, ypos)
			ypos+=fontHeight+4
			canvas.Color = Color.Green
			GAME.DrawText(canvas, "[D] Change Device to Keyboard",0,ypos)
			ypos+=fontHeight
			GAME.DrawText(canvas, "[ESCAPE] Back", 0, ypos)
			Return
		Endif

		' continue
		' first we draw the joystick label
		' as part of the menu title

		ypos+=fontHeight
		GAME.DrawText(canvas, input.JoyStickLabel,0,ypos )

		'then the axes

		ypos+=fontHeight+4

		For Local control:=EachIn input.JoystickControls.Values
		   	canvas.Color = Color.White

			' select the correct color when programming this control
		   	If input.Programming and control.Programmed
		   		If _activeHighlight Then canvas.Color = Color.Red
			Endif

			GAME.DrawText(canvas, control.ToString(), 0, ypos)
			ypos+=fontHeight
		Next

		' draw footer or reconfigure message

		ypos+=4
		canvas.Color = Color.Green

		If input.Programming
			GAME.DrawText(canvas, "Select new input for '" + input.ProgrammedControl.Label + "'", 0, ypos)

			ypos+=fontHeight
			GAME.DrawText(canvas, "[ESCAPE] Cancel Configuration", 0, ypos)
		Else
			GAME.DrawText(canvas, "[D] Change Device to Keyboard",0,ypos)
			ypos+=fontHeight
			GAME.DrawText(canvas, "[ESCAPE] Back  [F12] Configure", 0, ypos)
		Endif
	End Method


	#Rem monkeydoc @hidden

	Draws menu backdrop border and returns the ypos of the top of the border.

	#End
	Method DrawMenuBorder:Float( canvas:Canvas, lines:Int)
		canvas.Color = Color.Black
		Local borderHeight:Int = lines * GAME.Style.DefaultFont.Height
		Local ypos:Int = GAME.Height / 2 - borderHeight / 2

		canvas.Alpha = 0.95
		canvas.DrawRect( New Rectf(11, ypos, GAME.Width - 11, ypos+1))
		canvas.DrawRect( New Rectf(10, ypos+1, GAME.Width - 10, ypos+borderHeight-1))
		canvas.DrawRect( New Rectf(11, ypos+borderHeight-1, GAME.Width - 11, ypos+borderHeight))

		Return ypos+1
	End Method

	Private

	'settings to make active line flash
	Const _activeItemTimerDelay:Int = 25
	Field _activeItemTimerCount:Int
	Field _activeHighlight:Bool

	'various menu modes
	Const MODE_MAINMENU:Int = 0
	Const MODE_AUDIO:Int = 1
	Const MODE_CONTROLS:Int = 2
	Field _mode:Int

End Class
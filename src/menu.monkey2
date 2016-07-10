
Namespace game2d

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
		If _mode = MODE_MAINMENU
			Select True
				Case Keyboard.KeyHit( Key.Escape )
					If _mode = MODE_MAINMENU Then GAME.Paused = False

'				Case Keyboard.KeyHit( Key.F10 )
'					_mode = MODE_AUDIO

				case Keyboard.KeyHit( Key.F11 )
					GAME.Fullscreen = Not GAME.Fullscreen

				Case Keyboard.KeyHit( Key.F12 )
					_mode = MODE_CONTROLS

				Case Keyboard.KeyHit( Key.Q )
					GAME.RequestStop()
				Case Keyboard.KeyHit( Key.R )
					GAME.Paused = False
					GAME.OnRestartGame()
			End Select

		Elseif _mode = MODE_CONTROLS
			Select True
				Case Keyboard.KeyHit( Key.Escape )
					If Controller.GetInstance().Configuring
						Controller.GetInstance().Configuring = False
					Else
						_mode = MODE_MAINMENU
					Endif

				Case Keyboard.KeyHit( Key.F12)
					Controller.GetInstance().Configuring = True

					'restart line flash timer, start on
					_activeItemTimerCount = _activeItemTimerDelay
					_activeHighlight = True
				Default

					' waiting for a new key for active control.
					If Controller.GetInstance().Configuring
						local result:Bool = Controller.GetInstance().ScanKeyboard(_activeControlLabel)

						' restart flash timer, start on.
						if result
							_activeItemTimerCount = _activeItemTimerDelay
							_activeHighlight = True
						endif
					Endif

			End Select
		Elseif _mode = MODE_AUDIO
			Select True
				Case Keyboard.KeyHit( Key.Escape )
					_mode = MODE_MAINMENU

			End Select
		Endif

	End Method


	#Rem monkeydoc Renders the menu.
	#End
	Method Render:Void(canvas:Canvas)
		Local ypos:Int
		Select _mode
			Case MODE_MAINMENU 	DrawMainMenu(canvas)
			Case MODE_AUDIO		DrawAudioMenu(canvas)
			Case MODE_CONTROLS 	DrawControlsMenu(canvas)
		End Select
	End Method


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
		GAME.DrawText(canvas, "[Q] Exit To Desktop",0,ypos)
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

		Local configuring:Bool = Controller.GetInstance().Configuring
		Local fontHeight:Int = GAME.Style.DefaultFont.Height

		Local lines:Int = Controller.GetInstance().KeyControls.Count() + 3
		If configuring then lines+=1

		Local ypos:Int = DrawMenuBorder( canvas, lines)

		canvas.Alpha = 1.0
		canvas.Color = Color.Cyan
		If configuring
			GAME.DrawText(canvas, "Configure Controls", 0, ypos)

			_activeItemTimerCount-=1
			If _activeItemTimerCount<0
				_activeItemTimerCount = _activeItemTimerDelay
				_activeHighlight= Not _activeHighlight
			Endif
		Else
			GAME.DrawText(canvas, "Controls", 0, ypos)
		Endif

		ypos+=fontHeight+4
		Local index:Int = 0
		For Local item:=EachIn Controller.GetInstance().KeyControls
		   	Local label:= item.Key
		   	Local actualkey:= Keyboard.KeyName(item.Value)
		   	local text:String = label + ": " + actualkey

		   	' change color if we are configuring
		   	canvas.Color = Color.White
		   	If configuring and index = Controller.GetInstance().ConfiguringIndex
		   		If _activeHighlight Then canvas.Color = Color.Red
		   		_activeControlLabel = label
			Endif

			GAME.DrawText(canvas, text, 0, ypos)
			ypos+=fontHeight
			index+=1
		Next

		ypos+=4
		canvas.Color = Color.Green
		If configuring
			GAME.DrawText(canvas, "Select new key for '" + _activeControlLabel+ "'", 0, ypos)
			ypos+=fontHeight
			GAME.DrawText(canvas, "[ESCAPE] Cancel Configuration", 0, ypos)
		Else
			GAME.DrawText(canvas, "[ESCAPE] Back  [F12] Configure", 0, ypos)
		Endif

	End Method

	'returns the ypos of the top of the menu border.
	Method DrawMenuBorder:Float( canvas:Canvas, lines:Int)
		canvas.Color = Color.Black'DarkGrey

'		canvas.Alpha = 0.6
'		canvas.DrawRect(New Rectf(0,0, GAME.Width, GAME.Height))

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

	'this is the label of the currently active control.
	Field _activeControlLabel:String

	'various menu modes
	Const MODE_MAINMENU:Int = 0
	Const MODE_AUDIO:Int = 1
	Const MODE_CONTROLS:Int = 2

	Field _mode:Int

End Class
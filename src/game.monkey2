
Namespace game2d

'used by managers etc to get to the game instance.
'set when game class is created.
Global GAME:Game2d

Class Game2d Extends Window

	Method New(title:String, w:Int, h:Int, flags:WindowFlags)

		Super.New(title, w, h, flags)
		GAME = Self

		' get configuration from disk
		' create new one when not found
		' pass width and height so window size is set correctly after creating config file
		LoadConfig()

		Fullscreen = _config["fullscreen"].ToBool()

		Init()
	End Method

	Method Init:Void()

		' create managers and internal classes
		Controller.GetInstance()

		_menu = New Menu
		_timer = New FixedTime
		_states = New IntMap<State>

		_running = True
		_paused = False
		_vsync = 1
		_timer.Reset()
	End Method

	Property Paused:Bool()
		Return _paused
	Setter( value:Bool )
		_paused = value
		If _paused = True
			_menu.Reset()
		Else
			_timer.Reset()
		Endif
	End

	Property VSync:Bool()
		Return _vsync
	Setter( value:Bool )
		_vsync = value
	End

	Property Debug:Bool()
		Return _debug
	Setter( value:Bool )
		_debug = value
	End

	Property GameResolution:Vec2i()
		Return _virtualres
	Setter( value:Vec2i )
		_virtualres = value
		Super.MinSize = value
		OnMeasure()
	End


	Method OnMeasure:Vec2i() Override
		Return _virtualres
	End Method

	Property EnterTransition:Transition()
		Return _enterTransition
	Setter( value:Transition )
		_enterTransition = value
	End

	#Rem monkeydoc Adds state to the game.

	First state added becomes the startup state.

	#End
	Method AddState:Void(state:State, id:Int)
		_states.Add(id, state)
		state.Id = id
		state.Game = Self
		If _currentState = Null Then _currentState = state
	End Method


	#Rem monkeydoc Enters a state without a transition effect.
	#End
	Method EnterState:Void(id:Int)
		_currentState = _states.Get(id)
		DebugAssert( _currentState <> Null, "No state added!")
	End Method

	#Rem monkeydoc Enters a state with the provided transitions.

	Assumes there is already a current state.

	#End
	Method EnterState:Void(id:Int, enter:Transition=Null, leave:Transition=Null)
		_enterTransition = enter
		_leaveTransition = leave

		_nextState = _states.Get(id)
		DebugAssert( _nextState=True, "could not set nextstate with id " + id)

		If _leaveTransition Then _leaveTransition.Start()
	End Method


	' main loop
	' update and render
	Method OnRender(canvas:Canvas) Override

		App.RequestRender()

	'update

		If not _running Then Self.Stop()

		If Self.Paused
			_menu.Update()
		Else
			_timer.Update()

			While _timer.TimeStepNeeded()
				Self.GameUpdate()
			Wend
			If Keyboard.KeyHit( Key.Escape ) Then Self.Paused = True
		Endif

		' screenshot key here
		' ...

	'render

		Self.GameRender( canvas, _timer.Tween )
	End Method


	Method GameRender:Void(canvas:Canvas, tween:Double)

		canvas.TextureFilteringEnabled = False

		_currentState.PreRender(canvas, tween)

		EntityManager.GetInstance().Render( canvas, tween )

		_currentState.Render(canvas, tween)

		If _leaveTransition
			_leaveTransition.Render(canvas)
		ElseIf _enterTransition
			_enterTransition.Render(canvas)
		Endif

		If Self.Paused Then _menu.Render(canvas)

		_currentState.PostRender(canvas, tween)

		If _debug Then DrawDebug(canvas)
	End Method


	Method GameUpdate:Void()

		' update transition effect if it is active
		' there will be no game updates when a transition is active.

		If _leaveTransition
			_leaveTransition.Update()
			If _leaveTransition.Done = True
				_currentState.Leave()
				_leaveTransition = Null
				_currentState = _nextState
				_nextState = Null
				_currentState.Enter()
				If _enterTransition Then _enterTransition.Start()
			Else
				Return
			Endif
		ElseIf _enterTransition
			_enterTransition.Update()
			If _enterTransition.Done = True
				_enterTransition = Null
			Else
				Return
			Endif
		Endif

		_currentState.Update()
		EntityManager.GetInstance().Update()
	End Method


	Method DrawDebug:Void(canvas:Canvas)
		canvas.Color = Color.Green

'		Local ypos:Int = 0
'		Local ysize:Int = 11
		canvas.DrawText(""+ App.FPS, 0, 0)
	End Method

	#Rem monkeydoc Draws text, centered horizontally by default.
	#End
	Method DrawText:Void( canvas:Canvas, text:String, x:Int, y:Int, centered:Bool = True )

		If centered
			Local w:Int = Style.DefaultFont.TextWidth(text) / 2
			x = Width/2-w
		Endif
		canvas.DrawText( text, x, y )
	End Method

	#Rem monkeydoc User hook to call code when RESTART has been selected in the game menu.
	#End
	Method OnRestartGame:Void() Virtual
	End Method

	#Rem monkeydoc Requests the game to stop in the next update.
	#End
	Method RequestStop:Void()
		_running = False
	End Method

	#Rem monkeydoc Stops and exits the game.
	#End
	Method Stop:Void()

		'remove managers, etc.
		'....

		SaveConfig()
		App.Terminate()
	End Method

' configuration

	Method LoadConfig:Void()
		Local fileName:String = AppDir() + "config.json"
		Print( fileName)

		_config = JsonObject.Load( fileName )
		If Not _config

			Print( "no config loaded" )

			'cannnot load the config file, so create new config object

			_config = New JsonObject

			' screen items
			_config["fullscreen"] = New JsonBool(False)

			' controls
''			_config["up"] = New JsonNumber(Key.A)

''			_config["windowsize"]=New JsonArray( New JsonValue[](New JsonNumber(640), New JsonNumber(480)))


		Endif
	End Method


	Method SaveConfig:Void()

		'transfer settings from game to json object
		_config["fullscreen"] = New JsonBool(Fullscreen)

		Local s:String = AppDir() + "config.json"
		SaveString( _config.ToJson(),s)
	End Method


	Private

	Field _menu:Menu

	Field _timer:FixedTime

	Field _states:IntMap<State>
	Field _currentState:State
	Field _nextState:State
	Field _leaveTransition:Transition
	Field _enterTransition:Transition

	Field _paused:Bool
	Field _running:Bool
	Field _vsync:Bool

	' if true, additional info is drawn.
	Field _debug:Bool

	' game resolution, not physical resolution.
	Field _virtualres:Vec2i

	Field _config:JsonObject

End Class


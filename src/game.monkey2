
Namespace wdw.game2d

'used by managers etc to get to the game instance.
'set when game class is created.
Global GAME:Game2d


#Rem monkeydoc Base class of a Game2d instance.
#End
Class Game2d Extends Window

	Method New(title:String, w:Int, h:Int, flags:WindowFlags)

		Super.New(title, w, h, flags)
		GAME = Self

		Init()

	End Method

	' internal
	Method Init:Void()

		' create managers and internal classes

		InputManager.GetInstance()
		InputManager.GetInstance().DetectJoystick()
		EntityManager.GetInstance()

		' try to load the file config.json
		Self.LoadConfiguration()

		' use configuration to set the game instance preferences
		Fullscreen = _configuration["fullscreen"].ToBool()

		_menu = New Menu
		_timer = New FixedTime
		_states = New IntMap<State>
		_sounds = New StringMap<Sound>

		_running = True
		_paused = False
		_vsync = 1
		_timer.Reset()
	End Method

	#Rem monkeydoc Requests the game to stop in the next update.

	#End
	Method RequestStop:Void()
		_running = False
	End Method

	#Rem monkeydoc @hidden

	Stops and exits the game.

	#End
	Method Stop:Void()

		SaveConfiguration()

		'remove managers, etc.

		InputManager.GetInstance().Destroy()
		EntityManager.GetInstance().Destroy()

		App.Terminate()
	End Method


	#Rem monkeydoc Apply loaded configuration to the game

	This should be called after game setup so any controls that have been reconfigured will be changed.

	#End
	Method ApplyInputConfiguration:Void()
		InputManager.GetInstance().ApplyConfiguration(_configuration)
	End Method



	#Rem monkeydoc Pause flag.
	#End
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

	#Rem monkeydoc Render VSync flag.

	#End
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

	#Rem monkeydoc Returns or sets the game graphics resolution.
	#End
	Property GameResolution:Vec2i()
		Return _virtualres
	Setter( value:Vec2i )
		_virtualres = value
		Super.MinSize = value
		OnMeasure()
	End


	' internal
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
			If Keyboard.KeyHit( Key.Escape )
				Self.Paused = True
				InputManager.GetInstance().DetectJoystick()
			Endif
		Endif

		' screenshot key here
		' ...

	'render

		Self.GameRender( canvas, _timer.Tween )
	End Method


	' the actual rendering method.
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


	' the actual update method.
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

	' internal
	Method DrawDebug:Void(canvas:Canvas)
		canvas.Color = Color.Green
		canvas.DrawText(""+ App.FPS, 0, GAME.Height-10)
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



' *** audio ***


	#Rem monkeydoc Loads a sound from passed path to the sound library.

	@param path Path to load file from.

	@param name Name to store the sound with.

	#End
	Method AddSound:Void( path:String, name:String)
		Local sound:= Sound.Load(path)
		_sounds.Add(name, sound)
	End Method


	#Rem monkeydoc Plays the sound with passed name.

	@param name Name under which the sound is stored.

	@param loops The amount of times the sound must be played.

	@return The channel the sound is played on.

	#End
	Method PlaySound:Channel( name:String, loops:Int=0)
		Local sound:= _sounds.Get(name)
		DebugAssert( sound=true, "could not load sound" + name)
		Local channel:= sound.Play(loops)
		Return channel
	End Method



	Method LoadConfiguration:Void()

		Local fileName:String = AppDir() + "config.json"
		_configuration = JsonObject.Load( fileName )
		If Not _configuration

			Print( "config not loaded" )

			'could not load the json file
			'create a new one and set defaults for the game.

			_configuration = New JsonObject
			_configuration["fullscreen"]=New JsonBool( False )
			_configuration["windowsize"]=New JsonArray( New JsonValue[]( New JsonNumber(640), New JsonNumber(480) ) )
		Endif

		Print( "config loaded" )
	End Method



	Method SaveConfiguration:Void()

		_configuration = New JsonObject

		' get settings from the various game systems

	' --- game

		_configuration["fullscreen"] = New JsonBool( GAME.Fullscreen )

	' --- input

		Local keys:= New JsonArray
		For Local control:=Eachin InputManager.GetInstance().KeyboardControls.Values
			keys.Add( New JsonString( control.Label + ":" + control.ToJson() ) )
		Next
		_configuration["keyboardinput"] = keys

		local joybuttons:= New JsonArray
		For Local control:=Eachin InputManager.GetInstance().JoystickControls.Values
			If Cast<JoystickButtonControl>(control)
				joybuttons.Add( New JsonString( control.Label + ":" + control.ToJson() ) )
			Endif
		Next
		_configuration["joystickbuttons"] = joybuttons

		local joyaxes:= New JsonArray
		For Local control:=Eachin InputManager.GetInstance().JoystickControls.Values
			If Cast<JoystickAxisControl>(control)
				joyaxes.Add( New JsonString( control.Label + ":" + control.ToJson() ) )
			Endif
		Next
		_configuration["joystickaxes"] = joyaxes

		' process the json string  HACK

		Local s:String = AppDir() + "config.json"
		SaveString( _configuration.ToJson(), s )

		Print( "config saved" )
	End Method


	Property Configuration:JsonObject()
		Return _configuration
	End

	Private

	'sounds findable by name.
	Field _sounds:StringMap<Sound>

	Field _menu:Menu
	Field _timer:FixedTime

	Field _configuration:JsonObject

	Field _states:IntMap<State>
	Field _currentState:State
	Field _nextState:State
	Field _leaveTransition:Transition
	Field _enterTransition:Transition

	Field _paused:Bool
	Field _running:Bool
	Field _vsync:Bool

	' if true, additional debug info is drawn.
	' needs work.
	Field _debug:Bool

	' game resolution, not physical resolution.
	Field _virtualres:Vec2i


'	Field _configuration:JsonObject
End Class



#Rem monkeydoc Plays sound that is stored under passed name.

@param name Name under which the sound is stored.

@param loops Number of additional repeats of the sound.

#End
Function PlaySound:Channel( name:String, loops:Int = 0 )
	Local channel:= GAME.PlaySound(name, loops)
	Return channel
End Function

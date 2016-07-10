
Namespace game2d

#Rem monkeydoc Provides fixed update times for Game2d.

Based on: http://gafferongames.com/game-physics/fix-your-timestep/

#End
Class FixedTime

	#Rem monkeydoc Creates a new fixed time.

	Default update rate is 60 per second.

	#End
	Method New()
		UpdateFrequency = 60
	End Method

	#Rem monkeydoc Returns or sets the update frequency.
	#End

	Property UpdateFrequency:Double()
		Return _updateFrequency
	Setter( value:Double )
		_updateFrequency = value
		_deltatime = 1000.0:Double / value
	End

	#Rem monkeydoc Returns the current delta time.

	@return Double.

	#End
	Property DeltaTime:Double()
		Return _deltatime
	End

	#Rem monkeydoc Returns any left over time.

	@return Double.

	#End
	Property Tween:Double()
		Return _accumulator / _deltatime
	End

	#Rem monkeydoc Gets rid of passed time.
	#End
	Method Reset:Void()
		_time = Millisecs()
		_accumulator = 0
	End Method

	#Rem monkeydoc Updates the timer.
	#End
	Method Update:Void()
		Local thistime:Double = Millisecs()
		Local passedtime:Double = thistime - _time
		_time = thistime
		_accumulator+=passedtime
	End Method

	#Rem monkeydoc Returns true if more time has passed than a single update.

	@return True or False.

	#End
	Method TimeStepNeeded:Bool()
		If _accumulator >= _deltatime
			_accumulator-= _deltatime
			Return True
		Endif
		Return False
	End Method

	Private

	field _updateFrequency:Double
	Field _accumulator:Double
	Field _deltatime:Double
	Field _time:Double
	Field _tween:Double

End Class
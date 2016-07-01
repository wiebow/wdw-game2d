
Namespace game2d

#Rem monkeydoc
#End
Class FixedTime

	Method New()
		UpdateFrequency = 60
	End Method

	Property UpdateFrequency:Double()
		Return _updateFrequency
	Setter( value:Double )
		_updateFrequency = value
		_deltatime = 1000.0:Double / value
	End

	Property DeltaTime:Double()
		Return _deltatime
	End

	Property Tween:Double()
		Return _accumulator / _deltatime
	End

	Method Reset:Void()
		_time = Millisecs()
		_accumulator = 0
	End Method

	Method Update:Void()
		Local thistime:Double = Millisecs()
		Local passedtime:Double = thistime - _time
		_time = thistime
		_accumulator+=passedtime
	End Method


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
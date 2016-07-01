
Namespace game2d

#Rem monkeydoc Interpolated value.

Can be used for various purposes, like scale, position, color, etc.

Source: http://sol.gfxile.net/interpolation/

#End
Class InterPolated

	Method New( min:Float, max:Float, stepsTotal:Int, startStep:Int = -1)
		_minValue = min
		_maxValue = max
		_stepsTotal = stepsTotal

		_step = startStep
		If startStep = -1 then _step = stepsTotal / 2

		'default direction
		_stepDirection = 1

		'force first value
		Self.Update()
	End Method

	Property Value:Float()
		Return _value
	End

	Property StepDirection:Int()
		Return _stepDirection
	Setter( value:Int )
		_stepDirection = value
	End


	'this is ping pong update.
	'need to add more later.
	'also add true or false return value to signal end of update
	Method Update:Void()
	 	Local v:Float = _step / _stepsTotal
		v = Self.SmoothStep(v)
		_value = (_minValue * v) + (_maxValue * (1.0-v))

		'calculate next step, ping pong style.
		_step += _stepDirection
		If _step = _stepsTotal Then _stepDirection = -1
		If _step = 0 Then _stepDirection = 1
	End Method

	Private


	Method SmoothStep:Float(x:Float)
		Return x*x*(3-2*x)
	End Method

	Field _minValue:Float
	Field _maxValue:Float
	Field _value:Float

	Field _step:Float
	field _stepsTotal:Int
	Field _stepDirection:Int

End Class



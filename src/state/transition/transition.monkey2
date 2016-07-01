
Namespace game2d

#Rem monkeydoc Base class for state transition effects.

#End
Class Transition Abstract

	Method Start:Void() Virtual
	End Method

	Method Update:Void() Virtual
	End Method

	Method Render:Void( canvas:Canvas ) Virtual
	End Method

	Property Done:Bool() Final
		Return _done
	Setter( value:Bool )
		_done = value
	End

	Field _transitionLength:Int = 60
	Field _color:Color

	Private

	Field _done:Bool

End Class

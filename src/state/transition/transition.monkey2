
Namespace game2d

#Rem monkeydoc Base class for state transition effects.

#End
Class Transition Abstract

	#Rem monkeydoc user hook for transition setup.
	#End
	Method Start:Void() Virtual
	End Method

	#Rem monkeydoc user hook for transition update code.
	#End
	Method Update:Void() Virtual
	End Method

	#Rem monkeydoc user hook for transition render effect.
	#End
	Method Render:Void( canvas:Canvas ) Virtual
	End Method


	#Rem monkeydoc Returns true if the transition has completed.

	Extended transitions must set this flag.

	#End
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

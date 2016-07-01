
Namespace game2d

#Rem monkeydoc A game2d state.

A state is like a 'screen' or a 'mode'. Examples are a 'titlestate' or a 'playstate'.

#End
Class State Abstract

	'user hook for code when entering the state
	Method Enter:Void() Virtual
	End Method

	'user hook for code when leaving the state
	Method Leave:Void() virtual
	End Method

	Method OnRestartGame:Void() Virtual
	End Method

	' user hook for state update logic
	Method Update:Void() Virtual
	End Method

	Method PreRender:Void(canvas:Canvas, tween:Double) Virtual
	End Method

	' user hook for state render code
	Method Render:Void(canvas:Canvas, tween:Double) Virtual
	End Method

	Method PostRender:Void(canvas:Canvas, tween:Double) Virtual
	End Method

	Property Id:Int()
		Return _id
	Setter( id:Int )
		_id = id
	End

	Property Game:Game2d()
		Return _game
	Setter( game:Game2d )
		_game = game
	End

	Private

	Field _game:Game2d
	Field _id:Int


End Class

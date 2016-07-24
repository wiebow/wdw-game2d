
Namespace wdw.game2d

#Rem monkeydoc A game2d state.

A state is like a 'screen' or a 'mode'. Examples are a 'titlestate' or a 'playstate'.

#End
Class State Abstract

	#Rem monkeydoc user hook for code when entering the state
	#End
	Method Enter:Void() Virtual
	End Method

	#Rem monkeydoc user hook for code when leaving the state
	#End
	Method Leave:Void() virtual
	End Method

	#Rem monkeydoc user hook for code when restarting the game.
	#End
	Method OnRestartGame:Void() Virtual
	End Method

	#Rem monkeydoc user hook for state update logic.
	#End
	Method Update:Void() Virtual
	End Method

	#Rem monkeydoc user hook for render code that is being done before the main render pass

	Meaning anything drawn here will be below everything else.

	#End
	Method PreRender:Void(canvas:Canvas, tween:Double) Virtual
	End Method

	#Rem monkeydoc user hook for render code that is being done in the main render pass.

	The main render pass is done AFTER the entity manager is rendered.

	#End
	Method Render:Void(canvas:Canvas, tween:Double) Virtual
	End Method

	#Rem monkeydoc user hook for render code that is being done after the main render pass.

	Meaning anything drawn here will be on top of everything else.

	#End
	Method PostRender:Void(canvas:Canvas, tween:Double) Virtual
	End Method

	#Rem monkeydoc Returns or sets the ID of this state.

	@return Int

	#End
	Property Id:Int()
		Return _id
	Setter( id:Int )
		_id = id
	End

	#Rem monkeydoc Returns or sets the game instance this state belongs to.

	@return Game2d

	#End
	Property Game:Game2d()
		Return _game
	Setter( game:Game2d )
		_game = game
	End

	Private

	Field _game:Game2d
	Field _id:Int
End Class

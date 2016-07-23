
'various helper functions for game2d

Namespace wdw.game2d

#Rem monkeydoc Returns an array with the individual frames from the source image.

Default image handle is at the center.

#End
Function GrabAnimation:Image[]( source:Image, w:Int, h:Int, count:Int )
	local anim:= New Image[count]
	local x:Int = 0
	local y:int = 0

	For Local c:int = 0 until count
		anim[c] = New Image( source, New Recti( x,y,x+w,y+h) )
		anim[c].Handle = New Vec2f(0.5, 0.5)
		x+=w
		if x = source.Width
			x=0
			y+=h
			If y = source.Height Then Exit
		End If
	Next
	Return anim
End Function

#Rem monkeydoc Converts passed degrees to radians.

https://en.wikipedia.org/wiki/Radian

#End
Function DegreesToRadians:Float( degrees:Float )
	Return degrees*Pi/180
End Function

#Rem monkeydoc Converts passed radians to degrees.
#End
Function RadiansToDegrees:Float( radians:Float )
	Return radians*180/Pi
End Function

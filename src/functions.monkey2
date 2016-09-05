
'various helper functions for game2d

Namespace wdw.game2d

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

#Rem monkeydoc Plays sound that is stored under passed name.

@param name Name under which the sound is stored.

@param volume Loudness of the playback.

@param rate Playback rate (speed)

@param pan Position of sound. -1 is left, +1 is right.

@return Channel

#End
Function PlaySound:Channel( name:String, volume:Float=1.0, rate:Float=1.0, pan:Float=0.0, channel:Channel=Null  )

	Local sound := GAME.GetSound(name)
	If sound = Null Then RuntimeError("Playsound: Could not find sound with name: " + name)

	If channel = Null
		channel = sound.Play()
		channel.Volume = volume
		channel.Rate = rate
		channel.Pan = pan
	Else
		channel.Volume = volume
		channel.Rate = rate
		channel.Pan = pan
		channel.Play(sound)

	Endif
'	 Then channel = New Channel

	Return channel
End Function

#Rem monkeydoc Returns an image.

@param name Name under which the image was stored.

@return Image

#End
Function GetImage:Image(name:String)
	Return GAME.GetImage( name )
End Function

#Rem monkeydoc Returns a image from array.

@param name Name under which the image was stored.

@param frame Index of the frame to return.

@return Image

#End
Function GetImage:Image(name:String, frame:Int)
	Return GAME.GetImage( name, frame )
End Function

#Rem monkeydoc Returns all frames from image array.

@param name Name under which the image was stored.

@return Image Array

#End
Function GetAnimImage:Image[]( name:String )
	Return GAME.GetAnimImage( name )
End Function

#Rem monkeydoc Returns an array with the individual frames from the source image.

Default image handle is at the center.

#End
Function GrabAnimation:Image[]( source:Image, w:Int, h:Int, count:Int )

	DebugAssert( source<>null, "GrabAnimation: no source image!!!!")

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

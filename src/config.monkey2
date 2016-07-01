

Namespace game2d



#Rem monkeydoc Configuration handler.

Loads and saves in JSON

#End
Class ConfigManager

	Method Load:Void( fileName:String = "config.json")

		Local obj:= JsonObject.Load( fileName )
		If Not obj

			obj = New JsonObject
			obj[windowed]=New JsonBool( True )
			obj[windowsize]=New JsonArray( New JsonValue[](640,480) )
		Else

		Endif

	End Method



	Method Save:Void()

''		Lo'cal obj:= New JsonObject

		SaveString( obj.ToJson(),"config.json")


	End Method


End Class


Method ToJson:JsonValue( rect:Recti )
		Return New JsonArray( New JsonValue[]( New JsonNumber( rect.min.x ),New JsonNumber( rect.min.y ),New JsonNumber( rect.max.x ),New JsonNumber( rect.max.y ) ) )
	End



Namespace game2d

#Rem monkeydoc
#End
Class RenderLayer

	Method New()
		_entities = New List<Entity>
		_toAdd = New List<Entity>
		_toRemove = New List<Entity>
	End Method

	Method Clear:Void()
		_entities.Clear()
	End Method


	Method AddEntity( entity:Entity, locked:Bool = False)
		If locked
			_toAdd.Add(entity)
			Return
		Endif

		'entity can only be added once
		For Local current:= Eachin _entities
			If current = entity Then Return
		Next
'		If _entities.Contains(entity) then Return

		entity.RenderLayer = Self
		_entities.Add(entity)
	End Method

	Method RemoveEntity:Void( entity:Entity, locked:Bool = False )
		If locked
			_toRemove.Add(entity)
			Return
		Endif
		entity.RenderLayer = Null
		_entities.Remove(entity)
	End Method

	'updates all entities in this layer.
	Method Update:Void()
		For Local entity:= Eachin _entities
			entity.UpdatePosition()
			entity.Update()
		Next
	End Method

	'renders all entities in this layer
	Method Render:Void(canvas:Canvas, tween:Double)
		For Local entity:= Eachin _entities
			entity.Interpolate(tween)
			entity.Render(canvas)
		Next
	End Method

	'called after entity manager update has processed all entities
	'entities added or removed during update are handled here
	Method ProcessQueues:Void()
		For Local entity:= Eachin _toAdd
			Self.AddEntity(entity)
		Next
		_toAdd.Clear()

		For Local entity:= Eachin _toRemove
			Self.RemoveEntity(entity)
		Next
		_toRemove.Clear()
	End Method


	Property Entities:List<Entity>()
		Return _entities
	End


	Private

	'the entities in this render layer
	Field _entities:List<Entity>

	'entities added or removed while the entity manager was locked.
	Field _toAdd:List<Entity>
	Field _toRemove:List<Entity>

End Class
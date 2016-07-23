
Namespace wdw.game2d

#Rem monkeydoc A group of entities.
#End
Class EntityGroup

	Method New()
		_entities = New List<Entity>
		_toAdd = New List<Entity>
		_toRemove = New List<Entity>
	End Method

	#Rem monkeydoc Removes all entities from this group.
	#End
	Method Clear:Void()
		_entities.Clear()
	End Method

	#Rem monkeydoc Adds passed entity to this group.

	@param entity Entity to add to the group.

	@param locked If true, entity is added when the entity manager is no longer locked.

	#End
	Method AddEntity( entity:Entity, locked:Bool = False)
		If locked
			_toAdd.Add(entity)
			Return
		Endif

		'entity can only be added once.
		For Local current:= Eachin _entities
			If current = entity Then Return
		Next
		_entities.Add(entity)
	End Method

	#Rem monkeydoc Removes passed entity to this group.

	@param entity Entity to remove from the group.

	@param locked If true, entity is removed when the entity manager is no longer locked.

	#End
	Method RemoveEntity:Void( entity:Entity, locked:Bool = False )
		If locked
			_toRemove.Add(entity)
			Return
		Endif
		_entities.Remove(entity)
	End Method

	' entityects added or removed during locked state are processed here.
	' called by the entity manager when it is no longer locked.
	' do not call by yourself.
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

	#Rem monkeydoc Returns the entities in this group.

	@return List

	#End
	Property Entities:List<Entity>()
		Return _entities
	End

	Private

	Field _entities:List<Entity>
	Field _toAdd:List<Entity>
	Field _toRemove:List<Entity>

End Class

Namespace game2d

#Rem monkeydoc Game2d Entity Manager.
#End
Class EntityManager

	Function GetInstance:EntityManager()
		If Not _instance Then Return New EntityManager
		Return _instance
	End Function

	Method New()
		DebugAssert( _instance = False, "Unable to create another instance of singleton class: Controller")
		_instance = Self
		Self.Initialize()
	End Method

	Method Destroy()
		Self.ClearAll()
		Self._instance = Null
	End Method

	Method Initialize()
		_renderLayers = New IntMap<EntityGroup>
		_entityGroups = New StringMap<EntityGroup>
		_locked = False
	End Method


	Method Update:Void()

		_totals = 0

		_locked = True
		For Local renderLayer:= Eachin _renderLayers.Values
			_totals+= renderLayer.Entities.Count()
			For Local entity:= Eachin renderLayer.Entities
				entity.UpdatePosition()
				entity.Update()
			Next
		Next
		_locked = False

		' check if entities added or removed during update need to be added
		' or removed.
		For Local layer:= Eachin _renderLayers.Values
			layer.ProcessQueues()
		Next

		'same for entity groups
		For Local group:= Eachin _entityGroups.Values
			group.ProcessQueues()
		Next

	End Method

	#Rem monkeydoc Renders all entities in the manager.

	Entities are drawn by render layer. Layer 0 is rendered first, etc.

	@param tween Render tween value.

	#End
	Method Render:Void( canvas:Canvas, tween:Double )

		_locked = True
		For Local renderLayer:= Eachin _renderLayers.Values
			For Local entity:= Eachin renderLayer.Entities
				entity.Interpolate(tween)
				entity.Render(canvas)
			Next
'			renderLayer.Render(canvas, tween)
		Next
		_locked = False

		If GAME.Debug
			local color:= canvas.Color
			canvas.Color = Color.Green
			GAME.DrawText(canvas, "entities:" + _totals, 0, 10, False)
			canvas.Color = color
		Endif

	End Method


	#Rem monkeydoc Adds entity group with passed name to the manager.

	@param groupName The name of the entity group to add.

	@return The new group, or the group with the same name if it already existed.

	#End
	Method AddEntityGroup:EntityGroup( groupName:String )
		If _entityGroups.Contains(groupName) Then Return Self.GetEntityGroup( groupName)

		Local group:= New EntityGroup
		_entityGroups.Add(groupName, group)
		Return group
	End Method

	#Rem monkeydoc Returns entity group with passed name.

	@param groupName The name of the group to retrieve.

	@return List containing entities, or Null if the group does not exist.

	#End
	Method GetEntityGroup:EntityGroup(groupName:String)
		Return _entityGroups.Get(groupName)
	End Method

	#Rem monkeydoc Removes entity group from the manager.

	This will also remove all entities in that group from the manager.

	@param groupName Name of the group to remove.

	#End
	Method RemoveEntityGroup:Void( groupName:String )
		Local group:= GetEntityGroup(groupName)
		If group = Null Then Return

		'remove entities from the group
		For Local entity:= Eachin group.Entities
			entity.EntityGroup = Null
		Next

		'remove the group
		_entityGroups.Remove(groupName)
	End Method

	Method AddEntityToGroup:Void( entity:Entity, groupName:String )
		Local group:= Self.GetEntityGroup(groupName)
		If group = Null Then group = Self.AddEntityGroup(groupName)
		group.AddEntity(entity, _locked)

		'this is not problem to add even if locked
		entity.EntityGroup = group
	End Method

	#Rem monkeydoc Removes passed entity from its entity group.

	@param e The entity to remove from its group.

	#End
	Method RemoveEntityFromGroup:Void( entity:Entity )
		Local group:= entity.EntityGroup
		If group = Null Then Return
		group.RemoveEntity(entity, _locked)
		entity.EntityGroup = Null
	End Method

	#Rem monkeydoc Removes all entities from an entitygroup.

	@param groupName Name of the group to clear.

	#End
	Method ClearEntityGroup:Void(groupName:String)
		Local group:= Self.GetEntityGroup(groupName)
		If group = Null Then Return
		For Local entity:= Eachin group.Entities
			group.RemoveEntity(entity, _locked)
		Next
	End Method

	#Rem monkeydoc Adds render layer with passed index to the manager.

	A renderlayer is an entity group.

	@param index The index of the layer to add.

	@return The new layer, or the layer with the passed index.

	#End
	Method AddRenderLayer:EntityGroup( index:Int )
		If _renderLayers.Contains(index) Then Return Self.GetRenderLayer(index)
		Local layer:= New EntityGroup
		_renderLayers.Add(index, layer)
		Return layer
	End Method

	Method GetRenderLayer:EntityGroup(index:Int)
		Return _renderLayers.Get(index)
	End Method

	Method RemoveRenderLayer:Void( index:Int )
		Local layer:= GetRenderLayer(index)
		If layer = Null Then Return

		'remove layer reference in the entities.
		For Local entity:= Eachin layer.Entities
			entity.RenderLayer = Null
		Next

		'remove the layer
		_renderLayers.Remove(index)
	End Method

	Method AddEntityToRenderLayer:Void(e:Entity, layerIndex:Int)

		' check if render layer exists. Create it if not.
		Local layer:= Self.GetRenderLayer(layerIndex)
		If Not layer Then layer = Self.AddRenderLayer(layerIndex)

		' add entity to layer, pass locked flag
		layer.AddEntity(e, _locked)

		e.RenderLayer = layer
	End Method


	#Rem monkeydoc Removes passed entity from its render layer.

	@param e The entity to remove from its render layer.

	#End
	Method RemoveEntityFromRenderLayer:Void(e:Entity)
		Local layer:= e.RenderLayer
		If layer = Null Then Return
		layer.RemoveEntity(e, _locked)
		e.RenderLayer = Null
	End Method

	#Rem monkeydoc Removes passed entity from manager.

	@param e Entity to remove.

	#End
	Method RemoveEntity:Void(e:Entity)
		Self.RemoveEntityFromRenderLayer(e)
		Self.RemoveEntityFromGroup(e)
	End Method

	#Rem monkeydoc Removes all entities from the manager.
	#End
	Method RemoveAllEntities:Void()
		For Local renderLayer:= Eachin _renderLayers.Values
			renderLayer.Clear()
		Next
		For Local entityGroup:= Eachin _entityGroups.Values
			entityGroup.Clear()
		Next
	End Method

	#Rem monkeydoc Removes all entities, groups and layers from the manager.
	#End
	Method ClearAll:Void()
		Self.RemoveAllEntities()
		_renderLayers.Clear()
		_entityGroups.Clear()
	End Method

	Private

	Global _instance:EntityManager

	'manager is locked during updates and render passes
	Field _locked:Bool

	Field _totals:Int

	Field _renderLayers:IntMap<EntityGroup>
	Field _entityGroups:StringMap<EntityGroup>

End Class

#Rem monkeydoc Adds entity to the manager.

The renderlayer and entitygroup are added to the manager if they do not exist.

@param entity The entity to add.

@param renderLayer Layer index to add the entity to.

#End
Function AddEntity:Void( entity:Entity, renderLayer:Int)
	EntityManager.GetInstance().AddEntityToRenderLayer(entity, renderLayer)
End Function

#Rem monkeydoc Removes entity from the manager.

@param entity The entity to remove.

#End
Function RemoveEntity:Void( entity:Entity )
	EntityManager.GetInstance().RemoveEntity(entity)
End Function

Function AddEntityToGroup:Void( entity:Entity, group:String )
	EntityManager.GetInstance().AddEntityToGroup( entity, group )
End Function

Function GetEntityGroup:EntityGroup( group:String )
	Return EntityManager.GetInstance().GetEntityGroup(group)
End Function

'Function RemoveEntityFromGroup:Void( entity:Entity, group:String )
'	EntityManager.GetInstance().AddEntityToGroup( entity, group )
'End Function

Function RemoveAllEntities:Void()
	EntityManager.GetInstance().RemoveAllEntities()
End Function

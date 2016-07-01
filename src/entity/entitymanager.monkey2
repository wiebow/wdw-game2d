
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
'		_entityList = New List<Entity>
		_renderLayers = New IntMap<RenderLayer>
		_entityGroups = New StringMap<List<Entity>>
		_locked = False
	End Method


	Method Update:Void()

		_locked = True
		For Local renderLayer:= Eachin _renderLayers.Values
			renderLayer.Update()
		Next
		_locked = False

		' check if entities added or removed during update need to be added
		' or removed.
		For Local renderLayer:= Eachin _renderLayers.Values
			renderLayer.ProcessQueues()
		Next
	End Method

	Method AddEntity:Void(e:Entity, layerIndex:Int)', groupName:String)

		' check if render layer exists. Create it if not.
		Local layer:= Self.GetRenderLayer(layerIndex)
		If Not layer Then layer = Self.AddRenderLayer(layerIndex)

		'check if group exists. if not, create it.
'		Local group:= Self.GetEntityGroup( groupName )
'		If Not group Then group = Self.AddEntityGroup( groupName )

'		_entityList.Add(e)
		layer.AddEntity(e, _locked)
	End Method


	#Rem monkeydoc Renders all entities in the manager.

	Entities are drawn by render layer. Layer 0 is rendered first, etc.

	@param tween Render tween value.

	#End
	Method Render:Void( canvas:Canvas, tween:Double )

		_locked = True
		For Local renderLayer:= Eachin _renderLayers.Values
			renderLayer.Render(canvas, tween)
		Next
		_locked = False

	End Method

	#Rem monkeydoc Adds entity group with passed name to the manager.

	@param groupName The name of the entity group to add.

	@return The new group, or the group with the same name if it already existed.

	#End
	Method AddEntityGroup:List<Entity>( groupName:String )
		If _entityGroups.Contains(groupName) Then Return Self.GetEntityGroup( groupName)
		Local group:= New List<Entity>
		_entityGroups.Add(groupName, group)
		Return group
	End Method

	#Rem monkeydoc Removes entity group from the manager.

	This will also remove all entities in that group from the manager.

	@param groupName Name of the group to remove.

	#End
	Method RemoveEntityGroup:Void( groupName:String )
		Local group:List<Entity> = GetEntityGroup(groupName)
		If group = Null Then Return

		For Local entity:= Eachin group
			Self.RemoveEntity(entity)
		Next
		_entityGroups.Remove(groupName)
	End Method

	#Rem monkeydoc Returns entity group with passed name.

	@param groupName The name of the group to retrieve.

	@return List containing entities, or Null if the group does not exist.

	#End
	Method GetEntityGroup:List<Entity>(groupName:String)
		Return _entityGroups.Get(groupName)
	End Method

	#Rem monkeydoc Removes passed entity from its entity group.

	@param e The entity to remove from its group.

	#End
	Method RemoveEntityFromGroup:Bool( e:Entity)
		Local group:= Self.GetEntityGroup(e.GroupName)
		If group = Null Then Return False
		e.GroupName = ""
		Return group.Remove(e)
	End Method

	Method AddEntityToGroup:Bool( e:Entity, groupName:String )
		Local group:= Self.GetEntityGroup(groupName)
		If group = Null Then group = Self.AddEntityGroup(groupName)
'		DebugAssert( group=true, "cannot find group " + groupName)

		e.GroupName = groupName
		group.Add(e)
		Return True
	End Method

	#Rem monkeydoc Removes all entities from an entitygroup.

	@param groupName Name of the group to clear.

	#End
	Method ClearEntityGroup:Bool(groupName:String)
		Local group:= Self.GetEntityGroup(groupName)
		If group = Null Then Return False
		For Local entity:= Eachin group
			group.Remove(entity)
		Next
		Return True
	End Method

	#Rem monkeydoc Adds render layer with passed index to the manager.

	@param index The index of the render layer to add.

	@return The new layer, or the layer with the passed index.

	#End
	Method AddRenderLayer:RenderLayer( index:Int )
		If _renderLayers.Contains(index) Then Return Self.GetRenderLayer(index)
		Local layer:= New RenderLayer
		_renderLayers.Add(index, layer)
		Return layer
	End Method

	Method GetRenderLayer:RenderLayer(index:Int)
		Return _renderLayers.Get(index)
	End Method

	Method AddEntityToRenderLayer:Bool(e:Entity, index:Int)
		Local layer:= _renderLayers.Get( index )
		If layer = Null Then Return False
		layer.AddEntity(e, _locked)
		Return True
	End Method

	#Rem monkeydoc Removes passed entity from its render layer.

	@param e The entity to remove from its render layer.

	#End
	Method RemoveEntityFromRenderLayer:Bool(e:Entity)
		Local layer:= e.RenderLayer
		If layer = Null Then Return False
		layer.RemoveEntity(e, _locked)
		Return True
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
'		For Local renderLayer:= Eachin _renderLayers.Values
'			For local entity:= Eachin renderLayer.Entities
'				RemoveEntityFromGroup(entity)
'			Next
'		Next
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

	Field _renderLayers:IntMap<RenderLayer>
	Field _entityGroups:StringMap<List<Entity>>

End Class

#Rem monkeydoc Adds entity to the manager.

The renderlayer and entitygroup are added to the manager if they do not exist.

@param entity The entity to add.

@param renderLayer Layer to add the entity to.

@param entityGroup Group to add the entity to.

#End
Function AddEntity:Void( entity:Entity, renderLayer:Int)', entityGroup:String )
	EntityManager.GetInstance().AddEntity(entity, renderLayer)', entityGroup)
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

Function GetEntityGroup:List<Entity>( group:String )
	Return EntityManager.GetInstance().GetEntityGroup(group)
End Function

'Function RemoveEntityFromGroup:Void( entity:Entity, group:String )
'	EntityManager.GetInstance().AddEntityToGroup( entity, group )
'End Function

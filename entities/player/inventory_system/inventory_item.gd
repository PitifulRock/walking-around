extends Resource
class_name InventoryItem

@export_category("Visuals")
@export var item_name : String = ""
@export var icon : Texture2D
@export var icon_albedo : Color = Color.WHITE
@export_category("Item Details")
@export var stackable : bool = true
@export var base_amount := 1
@export_category("References")
@export_file("*.tscn") var tool_scene_path : String
@export_file(".tres") var pickup_data : String

func _on_clicked(equipped : bool, connected_slot : Node):
	if !Master.local_player.is_multiplayer_authority():
		return
	var player_hand = Master.local_player.find_child("HandPoint")
	var spawn_scene = load(tool_scene_path)
	var scene = spawn_scene.instantiate()
	
	if equipped == false:
		for i:Tool in player_hand.get_children():
			if i.inv_item == self:
				i._unequip()
				break
	else:
		for i:Tool in player_hand.get_children():
			if i.inv_item == self:
				i._reequip()
				break
				return
			if !i.force_equipped: 
				i._unequip()
		
		Master.spawn_node_for_peers.rpc(tool_scene_path, Vector3.ZERO, player_hand.get_path())
		player_hand.add_child(scene)
		connected_slot.spawned_item = scene
		
		for i:Tool in player_hand.get_children(): 
			i.held = true
		print("spawned")

extends Resource
class_name InventoryItem

@export var item_name : String = ""
@export var icon : Texture2D
@export var stackable : bool = true
@export var base_amount := 1
@export_file("*.tscn") var spawn_scene_path : String
@export var tool : bool = false
@export_file("*.tscn") var tool_scene_path : String

var in_use := false

func _on_clicked():
	if !tool:
		var spawn_scene = load(spawn_scene_path)
		var scene = spawn_scene.instantiate()
		Master.game_manager.current_scene.add_child(scene)
		scene.global_position = Master.local_player.global_position
		Master.local_player.player_data._remove_from_inventory(self)
	else:
		var player_hand = Master.local_player.find_child("HandPoint")
		var spawn_scene = load(tool_scene_path)
		var scene = spawn_scene.instantiate()
		if !in_use:
			player_hand.add_child(scene)
		else:
			for i in player_hand.get_children():
				if i.name == scene.name and i is Tool:
					i._unequip()
		in_use = !in_use

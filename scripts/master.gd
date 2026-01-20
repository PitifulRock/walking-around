extends Node

signal lobby_closed

var local_player : Player:
	set(value):
		local_player = value
		if Console:
			Console._print("Local Player: ", local_player)
var player_list : Dictionary[int, Player] = {}
var game_manager : GameManager
var pickup_success := false

@rpc("any_peer", "reliable")
func request_pickup(pickup_path: NodePath, player_id: int, amount:=1, item_data := {}):
	if !multiplayer.is_server():
		return
	
	var pickup_node : ItemPickup = get_node_or_null(pickup_path)
	var player = Master.player_list[player_id]
	var item_resource_path = pickup_node.pickup_data.item.get_path()
	
	player._push_to_inv.rpc_id(player_id, item_resource_path, amount, item_data)
	
	if pickup_node:
		if player.inv_add_success and pickup_node.delete_on_pickup:
			rpc("delete_node", pickup_path)
			player.inv_add_success = false

@rpc("any_peer", "call_local", "reliable")
func delete_node(node_path: NodePath):
	var node_inst = get_node_or_null(node_path)
	if node_inst != null:
		node_inst.queue_free()

@rpc("any_peer", "call_local", "reliable")
func spawn_node(scene_path: NodePath, spawn_position:= Vector3.ZERO, spawn_path: NodePath = game_manager.current_scene.spawned_items_path.get_path()):
	var scene_resource = load(scene_path)
	if scene_resource != null:
		var scene_inst = scene_resource.instantiate()
		var node_path = get_node_or_null(spawn_path)
		if node_path == null:
			node_path = get_node_or_null(game_manager.current_scene.spawned_items.get_path())
		
		node_path.add_child(scene_inst)
		scene_inst.position = spawn_position

@rpc("any_peer", "call_remote", "reliable")
func spawn_node_for_peers(scene_path: NodePath, spawn_position:= Vector3.ZERO, spawn_path: NodePath = game_manager.current_scene.spawned_items_path.get_path(), disable_node := true):
	var scene_resource = load(scene_path)
	if scene_resource != null:
		var scene_inst : Node = scene_resource.instantiate()
		var node_path = get_node_or_null(spawn_path)
		if node_path == null:
			node_path = get_node_or_null(game_manager.current_scene.spawned_items.get_path())
		
		node_path.add_child(scene_inst)
		if disable_node: scene_inst.process_mode = scene_inst.PROCESS_MODE_DISABLED
		scene_inst.position = spawn_position

@rpc("any_peer", "call_local", "reliable")
func spawn_pickup(pickup_resource_path: String, spawn_position:= Vector3.ZERO, amount:=1, item_data := {}):
	var pickup_scene = preload("uid://dkbhxt3uqmiwp")
	var node_path = get_node_or_null(game_manager.current_scene.spawned_items.get_path())
	if pickup_scene != null:
		var pickup: ItemPickup = pickup_scene.instantiate()
		var pickup_info = load(pickup_resource_path)
		
		node_path.add_child(pickup)
		pickup.pickup_data = pickup_info
		pickup.item_data = item_data
		pickup.item_amount = amount
		pickup.position = spawn_position

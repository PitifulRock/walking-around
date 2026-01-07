extends Node

signal lobby_closed

var local_player : Player
var player_list : Dictionary[int, Player] = {}
var game_manager
var pickup_success := false

@rpc("any_peer", "reliable")
func request_pickup(pickup_path: NodePath, player_id: int):
	if !multiplayer.is_server():
		return
	
	var pickup_node : ItemPickup = get_node_or_null(pickup_path)
	var player = Master.player_list[player_id]
	var item_resource_path = pickup_node.item_data.get_path()
	
	player._push_to_inv.rpc_id(player_id, item_resource_path)
	
	if player.inv_add_success and pickup_node.delete_on_pickup:
		rpc("delete_node", pickup_path)
		player.inv_add_success = false

@rpc("any_peer", "call_local", "reliable")
func delete_node(node_path: NodePath):
	var node_inst = get_node_or_null(node_path)
	if node_inst != null:
		node_inst.queue_free()

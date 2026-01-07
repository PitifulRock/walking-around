extends Interactable
class_name ItemPickup

@export var pickup_data : PickupData
@export var item_data : InventoryItem
@export var delete_on_pickup := true

func _ready() -> void:
	super._ready()
	if pickup_data.model:
		var model = pickup_data.model.instantiate()
		add_child(model)
	interacted.connect(_pick_up)

#func _pick_up(player : Player):
	#if !player.player_data._add_to_inventory(item_data) == false and delete_on_pickup:
		#queue_free()

func _pick_up(player : Player):
	if !multiplayer.is_server():
		Master.request_pickup.rpc_id(1, get_path(), player.ID)
		return
	else:
		Master.request_pickup(get_path(), player.ID)

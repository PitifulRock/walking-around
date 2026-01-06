extends Interactable
class_name ItemPickup

@export var item_data : InventoryItem
@export var delete_on_pickup := true

func _ready() -> void:
	super._ready()
	interacted.connect(_pick_up)

func _pick_up(player : Player):
	if !player.player_data._add_to_inventory(item_data) == false and delete_on_pickup:
		queue_free()
	

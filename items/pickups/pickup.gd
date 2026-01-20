extends Interactable
class_name ItemPickup

@export var pickup_data : PickupData:
	set(value):
		if value != pickup_data:
			pickup_data = value
			setup(value)
@export var item_amount := 1
@export var delete_on_pickup := true
var item_data = {}

func _ready() -> void:
	super._ready()
	if pickup_data:
		setup(pickup_data)
	interacted.connect(_pick_up)

func setup(data : PickupData):
	if !data: return
	for i in get_children():
		if i is Tool: 
			i.queue_free()
	var model_scene = load(data.model_path)
	var model = model_scene.instantiate()
	add_child(model)

func _pick_up(player : Player):
	if !multiplayer.is_server():
		Master.request_pickup.rpc_id(1, get_path(), player.ID, item_amount, item_data)
		return
	else:
		Master.request_pickup(get_path(), player.ID, item_amount, item_data)

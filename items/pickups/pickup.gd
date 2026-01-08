extends Interactable
class_name ItemPickup

@export var pickup_data : PickupData:
	set(value):
		if value != pickup_data:
			pickup_data = value
			setup(value)
@export var item_amount := 1
@export var delete_on_pickup := true

func _ready() -> void:
	super._ready()
	if pickup_data:
		setup(pickup_data)
	interacted.connect(_pick_up)

func setup(data : PickupData):
	for i in get_children():
		if i is Tool: 
			i.queue_free()
	var model_scene = load(data.model_path)
	var model = model_scene.instantiate()
	add_child(model)
	if model is Tool:
		if model.disable_as_model: model.process_mode = Node.PROCESS_MODE_DISABLED

func _pick_up(player : Player):
	if !multiplayer.is_server():
		Master.request_pickup.rpc_id(1, get_path(), player.ID, item_amount)
		return
	else:
		Master.request_pickup(get_path(), player.ID, item_amount)

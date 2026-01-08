extends Tool

@export_category("Held Transform")
@export var held_rot := Vector3.ZERO
@export var held_offset := Vector3.ZERO
@export_category("Pickup Transform")
@export var pickup_rot := Vector3.ZERO
@export var pickup_offset := Vector3.ZERO

func _ready() -> void:
	super._ready()
	if held:
		rotation = held_rot
		position += held_offset
	else:
		rotation = pickup_rot
		position += pickup_offset

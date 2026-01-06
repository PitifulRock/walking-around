extends Node3D
class_name Tool

@onready var player := Master.local_player
@onready var player_data := Master.local_player.player_data

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("primary"):
		_primary()

func _ready() -> void:
	pass
func _primary():
	pass
func _unequip():
	pass

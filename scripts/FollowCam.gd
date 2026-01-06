extends Camera3D

@export var player: Player
@export var look_ahead_mult = 1.0
@export var down_offset = 1.0

var offset
@onready var default_x = rad_to_deg(rotation.x)

func _ready() -> void:
	offset = global_position - player.global_position

func _physics_process(_delta):
	var target_pos = player.global_position
	var look_ahead = -player.global_transform.basis.z * look_ahead_mult
	
	if player.input.y < 0:
		rotation.x = lerp_angle(rotation.x, deg_to_rad(default_x-down_offset), 0.1)
	else:
		rotation.x = lerp_angle(rotation.x, deg_to_rad(default_x), 0.1)
	
	global_position = global_position.lerp(target_pos+offset+look_ahead, 0.08)

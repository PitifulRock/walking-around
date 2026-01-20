extends Camera3D

@export var player: Player
@export var look_ahead_mult = 1.0
@export var look_ahead_mult_zoomed = 1.5
@export var down_offset = 1.0
var cur_look_ahead_mult = look_ahead_mult

@export var default_size = 9.2
@export var zoomed_out_size = 10.5
var current_size = default_size

var offset
@onready var default_x = rad_to_deg(rotation.x)

var t_delta : float

func _ready() -> void:
	offset = global_position - player.global_position

func _physics_process(delta):
	var target_pos = player.global_position
	var look_ahead = -player.global_transform.basis.z * cur_look_ahead_mult
	
	if player.input.y < 0:
		rotation.x = lerp_angle(rotation.x, deg_to_rad(default_x-down_offset), 0.1)
	else:
		rotation.x = lerp_angle(rotation.x, deg_to_rad(default_x), 0.1)
	
	global_position = global_position.lerp(target_pos+offset+look_ahead, 0.08)
	
	if Input.is_action_pressed("zoom"):
		current_size = lerpf(current_size, zoomed_out_size, 3.0*delta)
		cur_look_ahead_mult = lerpf(cur_look_ahead_mult, look_ahead_mult_zoomed, 3.0*delta)
	else:
		current_size = lerpf(current_size, default_size, 6.0*delta)
		cur_look_ahead_mult = lerpf(cur_look_ahead_mult, look_ahead_mult, 3.0*delta)
	size = current_size

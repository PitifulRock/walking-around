extends Node3D

@export var SENSITIVITY = 0.1
@onready var player: Player = $".."
@onready var cam: Camera3D = null
var enabled := false


func _input(event: InputEvent) -> void:
	if !enabled: return
	if !player.is_multiplayer_authority(): return
	if event is InputEventMouseMotion:
		player.rotate_y(-event.relative.x * SENSITIVITY/10)
		rotate_x(-event.relative.y * SENSITIVITY/10)
		rotation.x = clampf(rotation.x, PI/-2, PI/2)

func _physics_process(delta: float) -> void:
	if !cam: return
	cam.global_position = global_position
	if enabled:
		cam.global_rotation.x = lerp_angle(cam.global_rotation.x, global_rotation.x, 10.0*delta)
		cam.global_rotation.y = lerp_angle(cam.global_rotation.y, player.global_rotation.y, 10.0*delta)
	else:
		cam.global_rotation.x = global_rotation.x
		cam.global_rotation.y = player.global_rotation.y

func enable(new_cam : Camera3D = null):
	if new_cam: cam = new_cam
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	enabled = true
	player.can_move = false
	player.model.visible = false
	cam.global_rotation.x = global_rotation.x
	cam.global_rotation.y = player.global_rotation.y
	cam.make_current()

func disable():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	enabled = false
	player.can_move = true
	player.model.visible = true
	if cam: cam.clear_current()
	Master.local_player.main_camera.make_current()
	cam = null
	

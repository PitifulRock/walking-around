@tool
extends Tool

const IMG_PICKUP_PATCH = "uid://m3mk6pqlv3v7"
const MAX_BLUR := 4.0
var RANGE := MAX_BLUR*2.0
var CLARITY_SPOT := MAX_BLUR

@onready var cam_viewport_container: SubViewportContainer = %CamViewportContainer

@onready var focus_dial: TextureRect = %FocusDial
@onready var min_x: Control = %MinX
@onready var max_x: Control = %MaxX

@onready var blur: ShaderMaterial = %Blur.material
@onready var clarity_label:= %ClarityLabel
var enabled := false
var dial_focus : float = 4.0
var current_focus : float = 0.0
var blurriness := 4.0
var photo_clarity : int

func _ready() -> void:
	%CameraUI.visible = false
	dial_focus = randf_range(0.0, RANGE)
	_setup()

func _primary():
	if !enabled:
		cam_setup()
		player.fps_cam.enable(%FpsCamera)
		player.in_menu = true
		enabled = true
		%CameraUI.visible = true
	else:
		take_picture()

func cam_setup():
	dial_focus = randf_range(1.0, RANGE-1.0)
	if dial_focus <= MAX_BLUR and dial_focus > CLARITY_SPOT-0.6:
		_adjust_focus(-0.5)
	elif dial_focus >= MAX_BLUR and dial_focus < CLARITY_SPOT+0.6:
		_adjust_focus(0.5)
	current_focus = dial_focus
	_adjust_focus(0)

func _input(event: InputEvent) -> void:
	super._input(event)
	
	if enabled and Input.is_action_just_pressed("exit"):
		player.fps_cam.disable()
		enabled = false
		%CameraUI.visible = false
		await get_tree().create_timer(0.1).timeout
		player.in_menu = false
	if Input.is_action_just_released("scroll_up"):
		_adjust_focus(0.1)
	if Input.is_action_just_released("scroll_down"):
		_adjust_focus(-0.1)

func _adjust_focus(amt : float):
	dial_focus += amt
	dial_focus = clampf(dial_focus, 0.0, RANGE)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if !enabled: return
	current_focus = lerpf(current_focus, dial_focus, 4.0*delta)
	current_focus = clampf(current_focus, 0.0, RANGE)
	blurriness = abs(current_focus-CLARITY_SPOT)
	
	blur.set_shader_parameter("blur_amount", blurriness)
	photo_clarity = roundi((CLARITY_SPOT-blurriness)/CLARITY_SPOT * 100.0)
	if blurriness <= 0.055: photo_clarity = 100
	clarity_label.text = str("Clarity: ",photo_clarity,"%")
	
	update_visual()

func update_visual():
	var ui_range = max_x.position.x - min_x.position.x
	var focus_ui_pos = (current_focus/RANGE) * ui_range
	
	focus_dial.position.x = focus_ui_pos

func take_picture():
	var img: Image = %CamViewport.get_texture().get_image()
	img.resize(248, 248)
	var bytes = img.save_png_to_buffer()
	$AudioStreamPlayer.play()
	
	var animal_visibilities = get_animal_visibilities()
	var visible_animal_data_paths : Array[String]
	for animal_data in animal_visibilities:
		visible_animal_data_paths.append(animal_data.get_path())
	
	var image_score := roundi(float(animal_visibilities.size())/2 * photo_clarity)
	
	var img_data = {
		"image_bytes" : bytes,
		"clarity" : photo_clarity,
		"visible_animals" : visible_animal_data_paths,
		"image_rating" : image_score
	}
	
	Master.spawn_pickup(IMG_PICKUP_PATCH,player.global_position, 1, img_data)

func _on_unequip():
	player.fps_cam.disable()
	enabled = false
	%CameraUI.visible = false

func get_animal_visibilities() -> Array[AnimalData]: #[animal_data, perfectly_visible]
	var visible_animals : Array[AnimalData] = []
	var scene = Master.game_manager.current_scene
	if scene is not World: return []
	
	for i in scene.animal_path.get_children():
		if i is Animal:
			if is_in_view(i):
				visible_animals.append(i.animal_data)
	return visible_animals

func is_in_view(subject : Animal) -> bool:
	var camera : Camera3D = player.fps_cam.cam
	var frustum = camera.get_frustum()
	var subject_aabb = subject.global_transform * subject.get_aabb()
	
	for plane in frustum:
		if plane.is_point_over(subject_aabb.get_support(-plane.normal)):
			return false
	
	var ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.from = camera.global_transform.origin + Vector3.UP
	ray_params.collision_mask = 1
	
	var check_count = subject.visibility_checks.size()
	var collided_points := 0
	for i in subject.visibility_checks:
		ray_params.to = i.global_position
		if get_world_3d().direct_space_state.intersect_ray(ray_params):
			collided_points += 1
	
	if collided_points >= check_count:
		return false
	
	return true

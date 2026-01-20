class_name Player
extends CharacterBody3D

signal game_unpaused

@export var player_data : PlayerData
@onready var ID : int = self.name.to_int()
@onready var model: Node3D = $Model
@export var SPEED := 5.0
@export var SNEAK_SPEED := 2.5
@export var ACCELERATION := 12.0
@export var GRAVITY := 28.0

@export var inv_add_success := true

@onready var fps_cam: Node3D = $FpsHolder
@onready var main_camera: Camera3D = $PlayerCamera

var current_health : float
var current_speed := SPEED
var input : Vector2
var facing_dir : Vector3
var attention_captured := false

const PLAYER_UI = preload("uid://boq0nuabxsj4x")
var ui : Control

var spawned := false
var steam_name : String
var paused := false
var can_move := true
var in_menu := false

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _input(_event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	
	if Input.is_action_just_pressed("exit") and !in_menu:
		pause()

func pause():
	if paused:
		game_unpaused.emit()
	paused = !paused
	ui.pause_menu.visible = paused

func _ready() -> void:
	if !is_multiplayer_authority(): return
	player_data = PlayerData.new()
	current_health = player_data.max_health
	inv_add_success = !player_data.inventory_full
	spawn_sequence()

func spawn_sequence():
	
	current_health = player_data.max_health
	Master.local_player = self
	
	$CollisionShape3D.disabled = true
	global_position = Vector3.ZERO
	$NameTag.text = Steam.getPersonaName()
	$NameTag.visible = false
	$PlayerCamera.make_current()
	%AudioListener3D.make_current()
	
	ui = PLAYER_UI.instantiate()
	add_child(ui)
	ui.pause_menu.visible = false
	ui.pause_menu.player = self
	ui.pause_menu.player_id = self.name.to_int()
	
	await get_tree().create_timer(0.1).timeout
	$CollisionShape3D.disabled = false
	spawned = true

func _physics_process(delta: float) -> void:
	if !spawned: return
	if !is_multiplayer_authority(): return
	
	input = Input.get_vector("left", "right", "down", "up")
	var walking : bool
	
	if !paused and can_move:
		if input.length() > 0:
			walking = true
			var angle = input.angle() + deg_to_rad(45)
			facing_dir = Vector3(sin(angle),0.0,cos(angle)).normalized()
			rotation.y = lerp_angle(rotation.y, angle, 20*delta)
			var walk_velocity = -facing_dir * current_speed * player_data.speed_mult
			velocity = Vector3(walk_velocity.x, velocity.y, walk_velocity.z)
		else:
			walking = false
	else:
		walking = false
		input = Vector2.ZERO
	
	if !walking:
		velocity.x = lerpf(velocity.x, 0.0, ACCELERATION * delta)
		velocity.z = lerpf(velocity.z, 0.0, ACCELERATION * delta)
	
	if !is_on_floor():
		velocity.y -= GRAVITY * delta
		velocity.y = max(velocity.y, -20.0)
	
	$AnimationPlayer.speed_scale = 1+(player_data.speed_mult-1.0)/2
	
	if is_on_floor():
		if input.length() > 0:
			$AnimationPlayer.play("run")
		else:
			$AnimationPlayer.play("idle")
	else:
		if velocity.y > 0:
			$AnimationPlayer.play("airborne")
		else:
			$AnimationPlayer.play("fall")
	
	move_and_slide()

@rpc("any_peer", "call_local", "reliable")
func _push_to_inv(item_resource_path : String, amount:=1, item_data := {}):
	var item : InventoryItem = load(item_resource_path)
	if item != null:
		if player_data._add_to_inventory(item, amount, item_data) != false:
			inv_add_success = true
		else:
			inv_add_success = false


func _on_hand_child_added(node: Node) -> void:
	if node is Tool:
		node.player = self

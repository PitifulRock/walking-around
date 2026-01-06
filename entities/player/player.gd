class_name Player
extends CharacterBody3D

signal game_unpaused

@export var player_data : PlayerData

@onready var ID : int = self.name.to_int()
@onready var model: Node3D = $Model

@export var SPEED := 4.4
@export var ACCELERATION := 12.0
@export var GRAVITY := 9.8
var current_health : float

var input : Vector2
var facing_dir : Vector3

const PLAYER_UI = preload("uid://boq0nuabxsj4x")
var ui : Control

var spawned := false
var steam_name : String
var paused := false

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _input(_event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	
	if Input.is_action_just_pressed("pause"):
		pause()

func pause():
	if paused:
		game_unpaused.emit()
	paused = !paused
	ui.pause_menu.visible = paused

func _ready() -> void:
	if player_data: player_data = PlayerData.new()
	current_health = player_data.max_health
	spawn_sequence()

func spawn_sequence():
	if !is_multiplayer_authority(): return
	
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
	if !spawned or paused: return
	
	if !is_multiplayer_authority(): return
	
	input = Input.get_vector("left", "right", "down", "up")
	
	if input.length() > 0:
		var angle = input.angle() + deg_to_rad(45)
		facing_dir = Vector3(sin(angle),0.0,cos(angle)).normalized()
		rotation.y = lerp_angle(rotation.y, angle, 20*delta)
		velocity = -facing_dir * SPEED * player_data.speed_mult
	else:
		velocity = velocity.lerp(Vector3.ZERO, ACCELERATION * delta)
	
	if !is_on_floor():
		velocity.y = -GRAVITY
	
	$AnimationPlayer.speed_scale = 1+(player_data.speed_mult-1.0)/2
	if input.length() > 0:
		$AnimationPlayer.play("run")
	else:
		$AnimationPlayer.play("idle")
		$GPUParticles3D.emitting = false
	
	move_and_slide()
	

class_name Player
extends CharacterBody3D

@onready var ID : int = self.name.to_int()

@export var SPEED := 260.0
@export var ACCELERATION := 0.2
@export var GRAVITY := 9.8

var input : Vector2

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
	paused = !paused
	ui.pause_menu.visible = paused

func _ready() -> void:
	spawn_sequence()

func spawn_sequence():
	if !is_multiplayer_authority(): return
	
	Manager.local_player = self
	$CollisionShape3D.disabled = true
	global_position = Vector3.ZERO
	$NameTag.text = Steam.getPersonaName()
	$NameTag.visible = false
	$PlayerCamera.make_current()
	%AudioListener3D.make_current()
	ui = PLAYER_UI.instantiate()
	add_child(ui)
	ui.pause_menu.visible = false
	
	await get_tree().create_timer(0.1).timeout
	$CollisionShape3D.disabled = false
	spawned = true

func _physics_process(delta: float) -> void:
	if !spawned or paused: return
	
	if !is_multiplayer_authority(): return
	
	input = Input.get_vector("left", "right", "down", "up")
	
	if input.length() > 0:
		rotation.y = lerp_angle(rotation.y, input.angle() + deg_to_rad(45), 20*delta)
		velocity = -global_transform.basis.z * SPEED * delta
	else:
		velocity = velocity.lerp(Vector3.ZERO, ACCELERATION)
	
	if !is_on_floor():
		velocity.y = -GRAVITY
	
	if input.length() > 0:
		$AnimationPlayer.play("run")
	else:
		$AnimationPlayer.play("idle")
		$GPUParticles3D.emitting = false
	
	move_and_slide()
	

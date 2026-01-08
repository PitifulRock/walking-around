class_name Interactable
extends Area3D

#@export var delete_on_interact := false
@export var indicator : Node

var in_range := false
var off_cooldown := true
var current_player : Player

signal interacted
signal entered
signal exited

func _ready() -> void:
	body_entered.connect(_entered)
	body_exited.connect(_exited)
	if indicator: indicator.visible = false
	if get_collision_mask_value(2) == false:
		set_collision_layer_value(2, true)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and in_range:
		_interact()

func _entered(body : Node3D):
	if body is Player and body.is_multiplayer_authority():
		current_player = body
		in_range = true
		body.attention_captured = true
		entered.emit()
		if indicator: indicator.visible = true

func _exited(body : Node3D):
	if body is Player and body.is_multiplayer_authority():
		current_player = null
		in_range = false
		body.attention_captured = false
		exited.emit()
		if indicator: indicator.visible = false

func _interact():
	interacted.emit(current_player)
	if indicator: indicator.visible = false
	#if delete_on_interact: 
		#queue_free()
		#return
		
	_cooldown()

func _cooldown():
	off_cooldown = false
	await get_tree().create_timer(0.2).timeout
	off_cooldown = true

class_name Interactable
extends Area3D

@export var delete_on_interact := false
@export var indicator : Node

var in_range := false
var off_cooldown := true

signal interacted
signal entered
signal exited

func _ready() -> void:
	body_entered.connect(_entered)
	body_exited.connect(_exited)
	if indicator: indicator.visible = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and in_range:
		_interact()

func _entered(body : Node3D):
	if body is Player:
		in_range = true
		entered.emit()
		if indicator: indicator.visible = true

func _exited(body : Node3D):
	if body is Player:
		in_range = false
		exited.emit()
		if indicator: indicator.visible = false

func _interact():
	interacted.emit()
	if indicator: indicator.visible = false
	
	_cooldown()

func _cooldown():
	off_cooldown = false
	await get_tree().create_timer(0.2).timeout
	off_cooldown = true

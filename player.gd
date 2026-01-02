class_name Player
extends CharacterBody3D

@export var SPEED := 260.0
@export var ACCELERATION := 0.2
@export var GRAVITY := 9.8

var input : Vector2
@onready var dialogue_box = $UI/DialogueBox
@onready var dialogue_text: RichTextLabel = $UI/DialogueBox/DialogueText

func _ready() -> void:
	Manager.player = self

func _physics_process(delta: float) -> void:
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
	

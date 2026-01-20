@tool
extends Tool

@export var speed_mult = 0.6
@export var base_mult = speed_mult

func _ready() -> void:
	_setup()
	speed_mult = base_mult
	player_data.speed_mult += speed_mult

func _primary():
	player_data.speed_mult -= speed_mult
	speed_mult+=(base_mult/2)
	player_data.speed_mult += speed_mult
	spawn_particle()

func _on_unequip():
	player_data.speed_mult -= speed_mult

func spawn_particle():
	var new_particle = $GPUParticles3D.duplicate()
	add_child(new_particle)
	new_particle.restart()
	new_particle.emitting = true
	new_particle.finished.connect(func():
		remove_child(new_particle)
		new_particle.queue_free())

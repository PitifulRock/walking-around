extends Node3D
class_name NoiseEmitter

signal noise_emitted(noise_level : float)

@export var noise_mult := 1.0

func emit_noise(level : float = 4.0):
	noise_emitted.emit(level*noise_mult)

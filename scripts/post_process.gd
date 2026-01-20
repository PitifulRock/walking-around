extends Control

enum POST_PROCESS_EFFECT{PIXELIZATION}

@onready var pixelization_rect: ColorRect = $Pixelization

var pixelization := 2:
	set(value):
		pixelization = value
		if value > 0:
			pixelization_rect.material.set_shader_parameter("pixel_size", value)
		else:
			pixelization_rect.material.set_shader_parameter("pixel_size", 1)

func _ready() -> void:
	pixelization = SettingsManager.get_video_settings()["pixelization"]

func set_post_process_effect(effect : POST_PROCESS_EFFECT, on : bool):
	get_child(effect).visible = on
	pass

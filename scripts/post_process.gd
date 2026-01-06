extends Control

var pixelization := 2:
	set(value):
		pixelization = value
		if value > 0:
			$Pixelization.material.set_shader_parameter("pixel_size", value)
		else:
			$Pixelization.material.set_shader_parameter("pixel_size", 1)

func _ready() -> void:
	pixelization = SettingsManager.get_video_settings()["pixelization"]

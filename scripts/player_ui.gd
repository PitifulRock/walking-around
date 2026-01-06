extends Control

@onready var dialogue_box: Control = $CenterUI/DialogueBox
@onready var dialogue_text: RichTextLabel = $CenterUI/DialogueBox/DialogueText
@onready var pause_menu: Control = $CenterUI/PauseMenu
@onready var player = $".."

func _ready() -> void:
	%Minimap.texture = $MinimapViewport.get_texture()
	%CustomizeMenu.hide()

func _physics_process(_delta: float) -> void:
	%MinimapCam.global_position = Vector3(player.global_position.x, 15, player.global_position.z)
	#%MinimapCam.global_rotation.y = lerp_angle(%MinimapCam.global_rotation.y, player.global_rotation.y, 9*delta)

func _on_pixelization_slider_value_changed(value: float) -> void:
	Master.game_manager.post_process.pixelization = value
	if value > 0:
		%PixelText.text = str("Pixelization: ", int(value/2))
	else:
		%PixelText.text = str("Pixelization: OFF")

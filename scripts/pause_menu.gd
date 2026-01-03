extends Control

@onready var player_id = $"../..".name.to_int()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LabelID.text = str("Lobby ID: ", Manager.network_manager.lobby_id)
	

func _on_copy_button_pressed() -> void:
	DisplayServer.clipboard_set(str(Manager.network_manager.lobby_id))
func _on_leave_lobby_pressed() -> void:
	Manager.network_manager.remove_from_lobby(player_id)
	Manager.network_manager.show_menu()
func _on_quit_button_pressed() -> void:
	get_tree().quit()

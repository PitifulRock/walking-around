extends Node

var PLAYER_HATS := []

var config = ConfigFile.new()
const SETTINGS_PATH = "user://settings.ini"

func _ready() -> void:
	var hat_dir := DirAccess.open("res://entities/cosmetics/hats/")
	hat_dir.list_dir_begin()
	PLAYER_HATS = hat_dir.get_files()
	
	if !FileAccess.file_exists(SETTINGS_PATH):
		config.set_value("audio", "sfx_volume", 0.0)
		config.set_value("audio", "music_volume", 0.0)
		
		config.set_value("video", "pixelization", 2)
		
		config.set_value("player", "color", Color.WHITE)
		config.set_value("player", "hat", PLAYER_HATS[0])
		
		config.save(SETTINGS_PATH)
	else:
		config.load(SETTINGS_PATH)
	
	await get_tree().process_frame
	Master.game_manager.post_process.get_child(0)

func save_audio_setting(key:String, value):
	config.set_value("audio", key, value)
	config.save(SETTINGS_PATH)
func save_video_setting(key:String, value):
	config.set_value("video", key, value)
	config.save(SETTINGS_PATH)
func save_player_setting(key:String, value):
	config.set_value("player", key, value)
	config.save(SETTINGS_PATH)

func get_audio_settings():
	var audio_settings = {}
	for i in config.get_section_keys("aduio"):
		audio_settings[i] = config.get_value("audio", i)
	return audio_settings
func get_video_settings():
	var video_settings = {}
	for i in config.get_section_keys("video"):
		video_settings[i] = config.get_value("video", i)
	return video_settings
func get_player_settings():
	var player_settings = {}
	for i in config.get_section_keys("player"):
		player_settings[i] = config.get_value("player", i)
	return player_settings

@tool
extends Tool

@export var jump_amt := 14.0

func _primary():
	if player.is_on_floor():
		player.velocity += Vector3(0,jump_amt,0)
		$AudioStreamPlayer.play()

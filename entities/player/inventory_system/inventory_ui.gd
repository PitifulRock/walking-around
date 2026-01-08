extends GridContainer

@onready var slots : Array = get_children()
@onready var player_data : PlayerData = Master.local_player.player_data

func _unhandled_input(event: InputEvent) -> void:
	if !Master.local_player.is_multiplayer_authority():
		return
	if event is InputEventKey and !event.is_echo() and event.is_pressed():
		match event.keycode:
			Key.KEY_1, Key.KEY_KP_1, Key.KEY_END:
				slots[0].pressed()
				hide_popups()
			Key.KEY_2, Key.KEY_KP_2, Key.KEY_DOWN:
				slots[1].pressed()
				hide_popups()
			Key.KEY_3, Key.KEY_KP_3, Key.KEY_PAGEDOWN:
				slots[2].pressed()
				hide_popups()
			Key.KEY_4, Key.KEY_KP_4, Key.KEY_INSERT:
				slots[3].pressed()
				hide_popups()
			_:
				pass

func _ready() -> void:
	player_data.inventory_changed.connect(update_slots)
	update_slots()

func update_slots():
	for i in range(min(player_data.inventory.size(), slots.size())):
		slots[i].update(player_data.inventory[i])
func clear_slots_selected(excluded_slot : Node = self):
	for i in range(min(player_data.inventory.size(), slots.size())):
		if slots[i] != excluded_slot:
			slots[i].set_selected(false)
func hide_popups():
	for i in range(min(player_data.inventory.size(), slots.size())):
		slots[i].mouse_popup.hide()

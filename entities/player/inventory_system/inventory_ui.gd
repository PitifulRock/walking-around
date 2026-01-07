extends GridContainer

@onready var slots : Array = get_children()
@onready var player_data : PlayerData = Master.local_player.player_data

func _ready() -> void:
	player_data.inventory_changed.connect(update_slots)
	update_slots()

#func _process(delta: float) -> void:
	#for i in player_data.inventory:
		#print(i.item)

func update_slots():
	for i in range(min(player_data.inventory.size(), slots.size())):
		slots[i].update(player_data.inventory[i])

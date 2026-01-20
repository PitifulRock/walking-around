extends Resource
class_name InventorySlot

@export var item: InventoryItem
@export var amount: int:
	set(val):
		if val < 0: val = 0
		amount = val
@export var item_data: Dictionary

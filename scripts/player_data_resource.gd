class_name PlayerData
extends Resource

signal inventory_changed
signal inv_item_added

@export var max_health := 10.0
@export var speed_mult := 1.0
#@export var inventory_slots : int = 4
@export var inventory : Array[InventorySlot] = [
	InventorySlot.new(), InventorySlot.new(),
	InventorySlot.new(), InventorySlot.new()
	]

@export_group("Save Variables")
@export var last_position : Vector3 = Vector3.ZERO
@export var unlocked_hats : Array = ["empty_hat.tscn", "wizard_hat.tscn"]
@export var inventory_full := false

func _add_to_inventory(item : InventoryItem, passed_amount:=1, item_data := {}) -> bool:
	if passed_amount == 1: passed_amount = item.base_amount
	if item.stackable:
		var item_slots = inventory.filter(func(slot): return slot.item == item)
		if !item_slots.is_empty():
			item_slots[0].amount += passed_amount
		else:
			var empty_slots = inventory.filter(func(slot): return slot.item == null)
			if !empty_slots.is_empty():
				empty_slots[0].item = item
				empty_slots[0].amount = passed_amount
			else:
				inventory_full = true
				return false
	else:
		var empty_slots = inventory.filter(func(slot): return slot.item == null)
		if !empty_slots.is_empty():
			empty_slots[0].item = item
			empty_slots[0].amount = 1
			empty_slots[0].item_data = item_data
		else:
			inventory_full = true
			return false
	
	inventory_full = false
	inv_item_added.emit()
	inventory_changed.emit()
	return true

func _remove_from_inventory(item : InventoryItem, amount:=1):
	var item_slots = inventory.filter(func(slot): return slot.item == item)
	if !item_slots.is_empty():
		item_slots[0].amount -= amount
		if item_slots[0].amount <= 0:
			item_slots[0].item = null
			item_slots[0].item_data = {}
			inventory_changed.emit()
	else: return
	
	inventory_changed.emit()

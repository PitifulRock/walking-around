extends Control

@onready var item_icon: TextureRect = $ItemIcon
@onready var item_count: Label = $ItemCount
@onready var slot_button: TextureButton = $BgButton
@onready var item_name_label: Label = $ItemName
var held_item : InventoryItem
var item_amount : int
var item_equipped := false

func update(slot : InventorySlot):
	if !slot.item:
		item_icon.texture = null
		item_count.text = ""
		item_name_label.text = ""
		held_item = null
		return
	
	item_icon.texture = slot.item.icon
	if !slot.item.stackable:
		item_count.text = ""
	else:
		item_count.text = str(slot.amount)
	
	if slot.item.tool:
		slot_button.toggle_mode = true
	
	item_name_label.text = slot.item.item_name
	
	held_item = slot.item

func _on_button_pressed() -> void:
	if !held_item: return
	held_item._on_clicked()


func _on_bg_button_mouse_entered() -> void:
	$AnimationPlayer.play("hover_anim")
func _on_bg_button_mouse_exited() -> void:
	$AnimationPlayer.play_backwards("hover_anim")

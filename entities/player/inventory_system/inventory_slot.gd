extends Control

@onready var item_icon: TextureRect = $ItemIcon
@onready var item_count: Label = $BgButton/ItemCount
@onready var slot_button: TextureButton = $BgButton
@onready var item_name_label: Label = $ItemName
@onready var mouse_popup: Control = $MousePopup

var held_item : InventoryItem
var item_amount : int
var item_equipped := false
var selected := false
var spawned_item : Tool
var current_slot : InventorySlot

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("drop") and current_slot.item and spawned_item:
		_on_drop_one_pressed()
	
	if Input.is_action_just_pressed("drop_all") and current_slot.item and spawned_item:
		_on_drop_all_pressed()

func _ready() -> void:
	mouse_popup.hide()
	item_icon.material = item_icon.material.duplicate()

func update(slot : InventorySlot):
	current_slot = slot
	
	var re_equip := false
	if held_item != slot.item and slot_button.button_pressed:
		_on_button_toggled(false, false)
		re_equip = true

	if !slot.item:
		item_icon.material.set_shader_parameter("visible", false)
		item_count.text = ""
		item_name_label.text = ""
		held_item = null
		set_selected(false)
	else:
		item_icon.material.set_shader_parameter("visible", true)
		item_icon.material.set_shader_parameter("albedo_texture", slot.item.icon)
		item_icon.material.set_shader_parameter("albedo_color", slot.item.icon_albedo)
		
		if !slot.item.stackable:
			item_count.text = ""
		else:
			item_count.text = str(slot.amount)
		
		slot_button.toggle_mode = true
		item_name_label.text = slot.item.item_name
		held_item = slot.item
		mouse_popup.hide()
	
	if re_equip:
		_on_button_toggled(true, false)

func pressed():
	if slot_button.button_pressed: 
		_on_button_toggled(false, false)
	else:
		_on_button_toggled(!slot_button.button_pressed, false)
		get_parent().clear_slots_selected(self)

func _on_button_toggled(toggled_on: bool, mouse := true) -> void:
	if mouse == false:
		if toggled_on: 
			$MousePopup/EquipButton.text = "Unequip"
			if held_item: held_item._on_clicked(toggled_on, self)
		else:
			$MousePopup/EquipButton.text = "Equip"
			if spawned_item: held_item._on_clicked(toggled_on, self)
		
		if toggled_on: $AnimationPlayer.play("select_anim")
		else: $AnimationPlayer.play("RESET")
		if toggled_on != slot_button.button_pressed:
			slot_button.set_pressed_no_signal(toggled_on)
	else:
		if !mouse_popup.visible: 
			get_parent().hide_popups()
			mouse_popup.show()
		else: 
			mouse_popup.hide()
		slot_button.set_pressed_no_signal(!toggled_on)

func set_selected(on : bool):
	selected = on
	_on_button_toggled(on, false)
	slot_button.set_pressed_no_signal(on)

func _on_bg_button_mouse_entered() -> void:
	$AnimationPlayer.play("hover_anim")
func _on_bg_button_mouse_exited() -> void:
	$AnimationPlayer.play_backwards("hover_anim")


func _on_equip_button_pressed() -> void:
	pressed()
	mouse_popup.hide()

func _on_drop_all_pressed() -> void:
	mouse_popup.hide()
	if !current_slot.item: return
	if !spawned_item:
		Master.spawn_pickup(current_slot.item.pickup_data, Master.local_player.global_position, current_slot.amount)
	else:
		spawned_item._drop(current_slot.amount, true)
	Master.local_player.player_data._remove_from_inventory(held_item, current_slot.amount)
	
func _on_drop_one_pressed() -> void:
	mouse_popup.hide()
	if !current_slot.item: return
	if !spawned_item:
		Master.spawn_pickup(current_slot.item.pickup_data, Master.local_player.global_position, 1)
	else:
		if current_slot.amount-1 > 0:
			spawned_item._drop(1, false)
		else:
			spawned_item._drop(1, true)
	Master.local_player.player_data._remove_from_inventory(held_item, 1)

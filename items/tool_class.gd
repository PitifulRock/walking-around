extends Node3D
class_name Tool

var player : Player
var player_data : PlayerData
@export_file("*.tscn") var drop_pickup_path : String = "uid://dkbhxt3uqmiwp"
@export var pickup_data : PickupData
@export var inv_item : InventoryItem
@export var disable_as_model := true
@export var force_equipped := false

var held := false
var unequipping := false
var dropping := false
var can_primary = true

func _input(_event: InputEvent) -> void:
	if !held: return
	if !player.is_multiplayer_authority(): return
	if Input.is_action_just_pressed("primary") and can_primary:
		_primary()
		can_primary = false
		await  get_tree().create_timer(0.1).timeout
		can_primary = true

func _setup():
	if get_parent().name == "HandPoint": 
		held = true
		player_data = player.player_data

#func _process(delta: float) -> void:
	#print(get_path())

func _ready() -> void:
	_setup()
func _primary():
	pass

func _unequip():
	if unequipping: return
	unequipping = true
	_on_unequip()
	_delete()

func _on_unequip():
	pass

func _delete():
	held = false
	Master.delete_node.rpc(self.get_path())

func _drop(amount := 1, depleted := false):
	if unequipping: return
	if depleted:
		_unequip()
	Master.spawn_pickup.rpc(pickup_data.get_path(), Master.local_player.global_position, amount)
	dropping = false

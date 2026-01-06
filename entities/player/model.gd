extends Node3D

@onready var hat_holder: Marker3D = $Torso/Head/HatHolder

var default_material : Material = preload("uid://dbace8e3f85x0")
var current_material : Material
var body_meshes : Array[MeshInstance3D]
@export var player_color : Color = Color.WHITE:
	set(value):
		player_color = value
		if current_material:
			current_material.albedo_color = value

func _ready() -> void:
	current_material = default_material.duplicate()
	for i in get_all_children(self):
		if i is MeshInstance3D:
			body_meshes.append(i)
	for i : MeshInstance3D in body_meshes:
		i.set_surface_override_material(0, current_material)

func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		if child is not Marker3D:
			arr = get_all_children(child,arr)
	return arr

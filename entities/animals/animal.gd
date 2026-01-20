extends CharacterBody3D
class_name Animal

@export var visible_notifier: VisibleOnScreenNotifier3D
@export var animal_data : AnimalData

@export var mesh : MeshInstance3D
@export var visibility_checks : Array[Marker3D]

func _physics_process(_delta: float) -> void:
	pass

func get_aabb() -> AABB:
	return mesh.get_aabb()

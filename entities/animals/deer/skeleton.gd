
extends Skeleton3D

@export var IK_Dictionary : Dictionary[SkeletonIK3D, Marker3D]

func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	for i:SkeletonIK3D in IK_Dictionary.keys():
		i.target_node = IK_Dictionary[i].get_path()
	for i:SkeletonIK3D in IK_Dictionary.keys():
		i.start()


func _process(delta: float) -> void:
	if Master.local_player:
		#var look_pos = Master.local_player.global_position + Vector3(0,1.0,0)
		var look_pos = Master.local_player.fps_cam.global_position - Vector3(0,0.5,0)
		$HeadPivot.look_at(look_pos)
		if $HeadPivot.global_rotation.y < deg_to_rad(-80) or $HeadPivot.global_rotation.y > deg_to_rad(80):
			$HeadIK.interpolation = lerpf($HeadIK.interpolation, 0.0, 2.0*delta)
		else:
			$HeadIK.interpolation = lerpf($HeadIK.interpolation, 1.0, 2.0*delta)

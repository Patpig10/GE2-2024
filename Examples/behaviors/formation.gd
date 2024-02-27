extends Node3D

@export var leader_prefab:PackedScene
@export var follower_prefab:PackedScene

@export var count:int= 10
@export var gap:float = 10

func _ready():
	var leader = leader_prefab.instantiate()
	$"../".call_deferred("add_child", leader)
		
	leader.global_transform.basis = global_transform.basis
	leader.global_transform.origin = global_transform.origin
	for i in range(count):
		var offset = Vector3(gap, 0, gap) * (i + 1)		
		var follower = follower_prefab.instantiate()
		follower.leader_target_path = leader.get_path()
		follower.leader_target = leader
		$"../".call_deferred("add_child", follower)
		
		follower.position = transform * offset
		
		offset = Vector3(- gap, 0, gap) * (i + 1)		
		follower = follower_prefab.instantiate()
		follower.transform.origin = transform * offset
		follower.rotation = rotation
		

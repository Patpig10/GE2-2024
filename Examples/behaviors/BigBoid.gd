extends CharacterBody3D

@export var max_speed:float = 10
@export var force:Vector3
@export var acceleration:Vector3
@export var target_node_path:NodePath

@export var mass:float = 1
@export var slowing_distance = 5


func draw_gizmos():
	DebugDraw3D.draw_arrow(global_position, global_position + force, Color.AQUA, 0.1)
	DebugDraw3D.draw_arrow(global_position, global_position + velocity, Color.YELLOW, 0.1)

	DebugDraw3D.draw_sphere(target.global_position, slowing_distance, Color.BLUE_VIOLET)

var target:Node3D

func _ready():
	target = get_node(target_node_path)	
	
func arrive(target_pos:Vector3, slowing:float):
	var to_target = target_pos - global_position
	var dist = to_target.length()
	var ramped = dist / slowing
	var clamped = min(ramped, slowing)
	var desired = (to_target * clamped) / dist
	return desired - velocity
	
	
func seek(target_pos:Vector3):
	var to_target = target_pos - global_position
	var desired = to_target.normalized() * max_speed
	return desired - velocity
	
func _physics_process(delta):
	force = arrive(target.global_position, slowing_distance)
	acceleration = force / mass
	
	velocity = velocity + acceleration * delta
	if velocity.length() > 0:
		look_at(position - velocity)
		# global_transform.basis.z  = velocity.normalized()
		# global_transform = global_transform.orthonormalized()
	
	move_and_slide()
	draw_gizmos()
	

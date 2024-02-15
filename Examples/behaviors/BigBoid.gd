class_name BigBoid
extends CharacterBody3D

@export var max_speed:float = 10
@export var force:Vector3
@export var acceleration:Vector3
@export var target_node_path:NodePath

@export var mass:float = 1
@export var slowing_distance = 5

@export var damping:float = 0.1
@export var banking:float = 0.1

@export var seek_enabled:bool=true
@export var arrive_enabled:bool=false
@export var player_enabled:bool=false
@export var follow_path:bool=false
@export var looped:bool=true

@export var flee_enabled:bool=false
@onready var flee_target:Node3D=get_node("../enemy")

@export var pursue_enabled:bool=false
@export var pursue_target_path:NodePath
@onready var pursue_target:Node3D=get_node(pursue_target_path)

@export var offset_pursue_enabled:bool=false
@export var leader_target_path:NodePath
@onready var leader_target:Node3D=get_node(leader_target_path)

var offset:Vector3

@onready var path:Path3D=get_node("../Path3D")

var current:int = 0 

func follow():
	var target = path.global_transform * (path.get_curve().get_point_position(current))
	var len = path.get_curve().get_point_count()
	var to_target = target - global_position
	var dist = to_target.length()
	if dist < 2:
		if not looped and current == len - 1:
			return arrive(target, slowing_distance)
		else:
			current = (current + 1) % len
	return seek(target)

func draw_gizmos():
	DebugDraw3D.draw_arrow(global_position, global_position + force, Color.RED, 0.1)
	DebugDraw3D.draw_arrow(global_position, global_position + velocity, Color.YELLOW, 0.1)

	DebugDraw3D.draw_sphere(target.global_position, slowing_distance, Color.BLUE_VIOLET)

var target:Node3D
func _ready():
	target = get_node(target_node_path)	
	
	if offset_pursue_enabled:
		offset = global_position - leader_target.global_position
		offset = offset * leader_target.global_transform.basis
	
func arrive(target_pos:Vector3, slowing:float):
	var to_target = target_pos - global_position
	var dist = to_target.length()
	if dist == 0:
		return Vector3.ZERO
	var ramped = (dist / slowing) * max_speed
	var clamped = min(ramped, max_speed) 
	var desired = (to_target * clamped) / dist
	return desired - velocity
	
func offset_pursue(leader:BigBoid):
	var global_target = leader.transform * offset
	var to_target = global_target - global_position
	var dist = to_target.length()
	var t = dist / max_speed
	DebugDraw3D.draw_sphere(global_target, 0.1, Color.CHARTREUSE)
	var projected = global_target + leader.velocity * t
	DebugDraw3D.draw_sphere(projected, 0.1, Color.RED)

	return arrive(projected, 10)
	
func pursue(target_boid:BigBoid):
	var to_target = target_boid.global_position - global_position
	var dist = to_target.length()
	
	var t = dist / max_speed
	var projected = target_boid.global_position + target_boid.velocity * t
	
	DebugDraw3D.draw_arrow(target_boid.global_position, projected, Color.GREEN, 0.1)
	
	return seek(projected) 
	
func flee(target:Transform3D, flee_distance):
	var to_target = target.origin - global_position
	var dist = to_target.length()
	DebugDraw2D.set_text("dist", dist)
	if dist < flee_distance:
		var desired = to_target.normalized() * max_speed
		DebugDraw3D.draw_arrow(global_position, target.origin, Color.BLUE_VIOLET, 0.1)
		return velocity - desired
	else:
		return Vector3.ZERO
		
	
func seek(target_pos:Vector3):
	var to_target = target_pos - global_position
	var desired = to_target.normalized() * max_speed
	return desired - velocity
	
@export var power:float = 100
	
func player():
	var force = Vector3.ZERO
	var f = Input.get_axis("back", "forward")
	
	force = f * power * global_basis.z
	
	var s = Input.get_axis("left", "right")
	
	var projected = global_basis.x
	projected.y = 0
	projected = projected.normalized()
	
	force += s * power * projected
	
	return force
	pass	
func calculate():
	var force = Vector3.ZERO
	
	if seek_enabled:
		force += seek(target.global_position)
	if arrive_enabled:
		force += arrive(target.global_position, slowing_distance)
	if player_enabled:
		force += player()
	if follow_path:
		force += follow()
	if flee_enabled:
		force += flee(flee_target.global_transform, 5)
	if pursue_enabled:
		force += pursue(pursue_target)
	if offset_pursue_enabled:
		force += offset_pursue(leader_target)
	return force
	
func _physics_process(delta):
	
	force = calculate()
	acceleration = force / mass
	
	velocity = velocity + acceleration * delta
	if velocity.length() > 0:
		# look_at(position - velocity)
		# apply damping
		velocity -= velocity * delta * damping
					# global_transform.basis.z  = velocity.normalized()
		# global_transform = global_transform.orthonormalized()

		var temp_up = global_transform.basis.y.lerp(Vector3.UP + (acceleration * banking), delta * 5.0)
		look_at(global_transform.origin - velocity.normalized(), temp_up)
	
	move_and_slide()
	draw_gizmos()
	

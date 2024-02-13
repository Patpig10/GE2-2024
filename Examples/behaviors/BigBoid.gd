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

@onready var path:Path3D=get_node("../Path3D")

var current:int = 0 

func follow():
	var target = (path.get_curve().get_point_position(current))
	
	var to_target = target - global_position
	var dist = to_target.length()
	if dist < 2:
		current = (current + 1) % path.get_curve().get_point_count()
	return seek(target)

func draw_gizmos():
	DebugDraw3D.draw_arrow(global_position, global_position + force, Color.RED, 0.1)
	DebugDraw3D.draw_arrow(global_position, global_position + velocity, Color.YELLOW, 0.1)

	DebugDraw3D.draw_sphere(target.global_position, slowing_distance, Color.BLUE_VIOLET)

var target:Node3D
func _ready():
	target = get_node(target_node_path)	
	
func arrive(target_pos:Vector3, slowing:float):
	var to_target = target_pos - global_position
	var dist = to_target.length()
	var ramped = (dist / slowing) * max_speed
	var clamped = min(ramped, max_speed) 
	var desired = (to_target * clamped) / dist
	return desired - velocity
	
	
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
	

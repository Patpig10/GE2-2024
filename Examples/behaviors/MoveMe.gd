extends Marker3D


@export var range:float=20

func _on_timer_timeout():
	
	var p:Vector3
	
	p.x = randf_range(-range, range)
	# p.y = randf_range(-range, range)
	p.z = randf_range(-range, range)
	
	global_position = p 
	pass # Replace with function body.

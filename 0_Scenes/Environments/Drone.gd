extends RigidBody3D

@export var acceleration = 200.0
@export var steering_speed = 50.0
@export var max_speed = 120.0
@export var boost_multiplier = 1.5
@export var reverse_speed = -10.0
@export var backup_time = 1.0
@export var steering_tightness = 1 
@export var stuck_threshold = 0.5
@export var stuck_time = 1.5 

var target_node: Node3D = null
var stuck_timer = 0.0
var backup_timer = 0.0

func _physics_process(delta):
	if backup_timer > 0:
		backup_timer -= delta
		_move_backward()
		return
	if not target_node or not target_node.is_inside_tree():
		target_node = _find_nearest_target()
		return
	_navigate_to_target(delta)


func _navigate_to_target(delta: float) -> void:
	var target_direction = (target_node.global_transform.origin - global_transform.origin).normalized()
	var forward_vector = global_transform.basis.z
	var angle_to_target = forward_vector.angle_to(target_direction)
	var turn_direction = forward_vector.cross(target_direction).y
	var torque = turn_direction * angle_to_target * steering_speed * steering_tightness
	apply_torque(Vector3.UP * torque)
	var distance_to_target = global_transform.origin.distance_to(target_node.global_transform.origin)
	var speed_multiplier = boost_multiplier if distance_to_target > 10 else 1.0
	if linear_velocity.length() < max_speed * speed_multiplier:
		apply_central_impulse(forward_vector * acceleration * speed_multiplier * delta)
	if linear_velocity.length() < stuck_threshold:
		stuck_timer += delta
		if stuck_timer > stuck_time:
			stuck_timer = 0
			backup_timer = backup_time
	else:
		stuck_timer = 0


func _move_backward() -> void:
	var backward_vector = global_transform.basis.z
	apply_central_impulse(backward_vector * reverse_speed)


func _find_nearest_target() -> Node3D:
	var nearest_target: Node3D = null
	var shortest_distance = INF

	for target in get_tree().get_nodes_in_group("targets"):
		if target is Node3D and target != self:
			var distance = global_transform.origin.distance_to(target.global_transform.origin)
			if distance < shortest_distance:
				shortest_distance = distance
				nearest_target = target

	if nearest_target:
		print("New target found: ", nearest_target.name)
	return nearest_target

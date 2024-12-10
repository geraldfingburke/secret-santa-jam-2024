extends Camera3D

@export var target_path: NodePath  # Path to the target node
@export var follow_offset: Vector3 = Vector3(0, 5, -10)  # Offset relative to the target
@export var position_damping: float = 5.0  # Damping factor for smooth position transitions
@export var rotation_damping: float = 8.0  # Damping factor for smooth rotation transitions
@export var look_ahead_distance: float = 0.0  # Distance to look ahead in the target's movement direction

var target: Node3D

func _ready():
	# Cache the target node for performance
	if has_node(target_path):
		target = get_node(target_path)
	else:
		target = null
		push_error("Target node not found at path: %s" % target_path)

func _process(delta):
	if target:
		smooth_follow(delta)

# Smoothly follows the target with optional look-ahead
func smooth_follow(delta):
	# Target's current and future position
	var target_position = target.global_transform.origin
	var target_velocity = target.linear_velocity if "linear_velocity" in target else Vector3.ZERO
	var future_position = target_position + target_velocity * look_ahead_distance

	# Transform the offset relative to the target's basis
	var offset_position = target.global_transform.origin + target.global_transform.basis * follow_offset

	# Smoothly interpolate the camera's position
	global_transform.origin = global_transform.origin.lerp(offset_position, delta * position_damping)

	# Smoothly adjust rotation to look at the target
	var look_at_target = future_position
	var current_basis = global_transform.basis
	var target_basis = Transform3D().looking_at(look_at_target - global_transform.origin, Vector3.UP).basis
	global_transform.basis = current_basis.slerp(target_basis, delta * rotation_damping)

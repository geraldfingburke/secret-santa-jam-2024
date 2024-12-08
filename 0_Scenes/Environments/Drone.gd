extends VehicleBody3D

@export var speed = 100
@export var max_steering_angle = 180.0 # Maximum steering range in degrees
@export var stuck_check_interval = 2.0 # Time interval to check for being stuck (seconds)
@export var stuck_distance_threshold = 1.0 # Minimum distance change to avoid being considered stuck

var stuck_timer = 0.0
var last_position = Vector3.ZERO
var is_backing_up = false
var backup_timer = 0.0
@export var backup_duration = 1.5 # Time to spend backing up when stuck (seconds)

# Function to find the nearest body
func find_nearest_body() -> Node3D:
	var nearest_body = null
	var nearest_distance = INF
	
	for body in get_tree().get_nodes_in_group("targets"): # Ensure target bodies are in the "targets" group
		if body is Node3D:
			var distance = global_transform.origin.distance_to(body.global_transform.origin)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_body = body
	return nearest_body

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_backing_up:
		handle_backup(delta)
		return
	
	# Regular forward movement logic
	engine_force = speed

	# Find the nearest body
	var nearest_body = find_nearest_body()
	if nearest_body:
		# Calculate the direction to the nearest body
		var direction_to_body = (nearest_body.global_transform.origin - global_transform.origin).normalized()
		var forward_direction = -global_transform.basis.z.normalized()  # Vehicle's forward direction (negative Z)
		
		# Calculate the angle difference in radians
		var angle_difference = forward_direction.angle_to(direction_to_body)
		
		# Determine steering direction using the cross product
		var cross_product = forward_direction.cross(direction_to_body).y
		if cross_product < 0:
			angle_difference = -angle_difference
		
		# Convert the angle to degrees and wrap it to the range -180 to 180
		steering = wrapf(rad_to_deg(angle_difference), -180.0, 180.0)
		
		# Debug: Log the steering angle and target information
	else:
		# No nearest body found, reset steering
		steering = 0

	# Check for being stuck
	stuck_timer += delta
	if stuck_timer >= stuck_check_interval:
		check_stuck()
		stuck_timer = 0.0

# Check if the vehicle is stuck and initiate backing up
func check_stuck():
	var current_position = global_transform.origin
	var distance_moved = current_position.distance_to(last_position)
	print("Distance moved: ", distance_moved)
	
	if distance_moved < stuck_distance_threshold:
		print("Vehicle is stuck! Initiating backup.")
		is_backing_up = true
		backup_timer = 0.0
	
	last_position = current_position

# Handle the backup logic when stuck
func handle_backup(delta):
	backup_timer += delta
	print(backup_timer)
	engine_force = -speed  # Reverse
	steering = 0.5
	
	if backup_timer >= backup_duration:
		print("Backup complete. Resuming normal movement.")
		is_backing_up = false

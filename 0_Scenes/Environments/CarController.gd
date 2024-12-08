extends VehicleBody3D

@export var speed = 100
@export var handling = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	engine_force = Input.get_axis("reverse", "accelerate") * speed
	steering = Input.get_axis("horizontal-", "horizontal+") * handling

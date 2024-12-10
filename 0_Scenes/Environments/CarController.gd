extends VehicleBody3D

@export var speed = 100
@export var handling = 100

@onready var audio = $AudioStreamPlayer3D
var idle_sound = load("res://Sound/SFX/rally-car-idle-loop-17-84405.mp3")
var rev_sound = load("res://Sound/SFX/535040__freecarsoundsgaming__revving_2.ogg")

func _ready():
	# Initialize audio with idle sound
	audio.stream = idle_sound
	audio.play()

func _process(delta):
	handle_input()
	update_audio()

func handle_input():
	# Quit the game
	if Input.is_action_just_pressed("exit_game"):
		get_tree().quit()

	# Reload the current scene
	if Input.is_action_just_pressed("reload_scene"):
		get_tree().reload_current_scene()

	# Control engine force and steering
	engine_force = Input.get_axis("reverse", "accelerate") * speed
	steering = Input.get_axis("horizontal-", "horizontal+") * handling

	# Change audio stream based on acceleration
	if Input.is_action_just_pressed("accelerate"):
		set_audio_stream(rev_sound)
	elif Input.is_action_just_released("accelerate"):
		set_audio_stream(idle_sound)

func update_audio():
	# Adjust the volume based on engine force
	audio.volume_db = lerp(audio.volume_db, abs(engine_force * 0.1) + 1, 0.1)

func set_audio_stream(new_stream):
	# Smoothly transition between audio streams
	if audio.stream != new_stream:
		audio.stop()
		audio.stream = new_stream
		audio.play()

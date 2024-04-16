extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_used_device := -1

func _ready() -> void:
	print(Input.get_connected_joypads())
	for id in Input.get_connected_joypads():
		print("%s is known? %s" % [Input.get_joy_name(id), Input.is_joy_known(id)])


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		Input.stop_joy_vibration(0)
		Input.stop_joy_vibration(1)
		InputEnhancer.start_joy_vibration(last_used_device, 0.5, 0.5, 0.1)

	var direction = InputEnhancer.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	var rotate_direction = InputEnhancer.get_axis("rotate_left", "rotate_right")

	rotate(deg_to_rad(rotate_direction))
	move_and_slide()

func _input(event: InputEvent) -> void:
	if InputEnhancer.is_joy_motion_in_deadzone("ui_left", event):
		return
	last_used_device = event.device

extends CharacterBody3D

@export var min_angles := Vector2(0, -45)
@export var max_angles := Vector2(360, 90)

@export var current_angles := Vector2(0, 0)

@onready var horizontal_pivot: Node3D = %HorizontalPivot
@onready var vertical_pivot: Node3D = %VerticalPivot


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := InputEnhancer.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y))#.normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Based on https://stackoverflow.com/a/77147323/1816426
	var camera_rotation := InputEnhancer.get_vector("camera_rotate_left", "camera_rotate_right", "camera_rotate_up", "camera_rotate_down") * delta
	current_angles.x = wrapf(current_angles.x, -PI, PI) + camera_rotation.x
	current_angles.y = wrapf(current_angles.y, -PI, PI) + camera_rotation.y

	current_angles.x = clampf(
		wrapf(current_angles.x, -PI, PI),
		deg_to_rad(min_angles.x),
		deg_to_rad(max_angles.x)
	)

	current_angles.y = clampf(
		wrapf(current_angles.y, -PI, PI),
		deg_to_rad(min_angles.y),
		deg_to_rad(max_angles.y)
	)


	horizontal_pivot.basis = Basis(Vector3.UP, current_angles.x)
	vertical_pivot.basis = Basis(Vector3.RIGHT, current_angles.y)

	move_and_slide()

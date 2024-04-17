extends CharacterBody3D

@export var min_angles := Vector2(0, -45)
@export var max_angles := Vector2(360, 90)

@export var camera_angles := Vector2(0, 0)
@export var character_rotation := 0.0

@onready var horizontal_pivot: Node3D = %HorizontalPivot
@onready var vertical_pivot: Node3D = %VerticalPivot


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := InputEnhancer.get_axis("move_forward", "move_back")
	var input_rotation := InputEnhancer.get_axis("rotate_left", "rotate_right") * delta
	character_rotation = _set_angle(character_rotation, min_angles.x, max_angles.x, input_rotation)
	transform.basis = Basis(Vector3.UP, character_rotation)
	var direction := (transform.basis * Vector3(0, 0, input_dir))#.normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Based on https://stackoverflow.com/a/77147323/1816426
	var camera_rotation := InputEnhancer.get_vector("camera_rotate_left", "camera_rotate_right", "camera_rotate_up", "camera_rotate_down") * delta
	camera_angles.x =_set_angle(camera_angles.x, min_angles.x, max_angles.x, camera_rotation.x)
	camera_angles.y =_set_angle(camera_angles.y, min_angles.y, max_angles.y, camera_rotation.y)

	horizontal_pivot.basis = Basis(Vector3.UP, camera_angles.x)
	vertical_pivot.basis = Basis(Vector3.RIGHT, camera_angles.y)

	move_and_slide()

func _set_angle(current_angle, min_angle, max_angle, input_rotation):
	var new_angle = wrapf(current_angle, -PI, PI) + input_rotation

	new_angle = clampf(
		wrapf(new_angle, -PI, PI),
		deg_to_rad(min_angle),
		deg_to_rad(max_angle)
	)

	return new_angle

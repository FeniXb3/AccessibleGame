extends CharacterBody3D

@export var min_angles := Vector2(0, -45)
@export var max_angles := Vector2(360, 90)

@export var camera_angles := Vector2(0, 0)
@export var character_rotation := 0.0

@onready var horizontal_pivot: Node3D = %HorizontalPivot
@onready var vertical_pivot: Node3D = %VerticalPivot
@onready var model: Node3D = $Model
var animation_player: AnimationPlayer
var animations_to_loop := [
	"Idle",
	"Running_A",
	"Jump_Idle",
	"Walking_Backwards",
]
var was_on_floor_last_frame := false

const SPEED = 5.0
const JUMP_VELOCITY = 5.5

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	animation_player = model.find_child("AnimationPlayer")
	for animation_name in animations_to_loop:
		animation_player.get_animation(animation_name).loop_mode = Animation.LOOP_LINEAR

	animation_player.play("Idle")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


	if EnhancedInput.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input := EnhancedInput.get_vector("rotate_left", "rotate_right", "move_forward", "move_back")
	character_rotation = _set_angle(character_rotation, min_angles.x, max_angles.x, input.x * delta)

	transform.basis = Basis(Vector3.UP, character_rotation)
	var direction := (transform.basis * Vector3(0, 0, input.y))
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Based on https://stackoverflow.com/a/77147323/1816426
	var camera_rotation := EnhancedInput.get_vector("camera_rotate_left", "camera_rotate_right", "camera_rotate_up", "camera_rotate_down") * delta
	camera_angles.x =_set_angle(camera_angles.x, min_angles.x, max_angles.x, camera_rotation.x)
	camera_angles.y =_set_angle(camera_angles.y, min_angles.y, max_angles.y, camera_rotation.y)

	horizontal_pivot.basis = Basis(Vector3.UP, camera_angles.x)
	vertical_pivot.basis = Basis(Vector3.RIGHT, camera_angles.y)

	update_animation(direction, input)
	was_on_floor_last_frame = is_on_floor()
	move_and_slide()

func update_animation(direction: Vector3, input: Vector2) -> void:
	print(velocity.y)
	if not was_on_floor_last_frame and is_on_floor():
		animation_player.play("Jump_Land", 0.1)
		print ("jump land")
	elif is_on_floor():
		if velocity.y > 0:
			animation_player.play("Jump_Start", 0.1)
			#animation_player.queue("Jump_Idle")
			print ("jump start")
		elif input.y < 0:
			animation_player.play("Running_A", 0.5)
		elif input.y > 0:
			animation_player.play("Walking_Backwards", 0.5)
		else:
			animation_player.play("Idle", 0.5)
	#elif is_zero_approx(velocity.y):
	else:
		animation_player.queue("Jump_Idle")

func _set_angle(current_angle, min_angle, max_angle, input_rotation):
	var new_angle = wrapf(current_angle, -PI, PI) + input_rotation

	new_angle = clampf(
		wrapf(new_angle, -PI, PI),
		deg_to_rad(min_angle),
		deg_to_rad(max_angle)
	)

	return new_angle

extends Node

@export var limit_mouse_motion: bool = false
@export var mouse_velocity_reduction_scale: float = 100.0

var mouse_motion: Vector2
var mouse_velocity: Vector2
var mouse_wheel_counters: Dictionary
var mouse_motion_relative_max: int = 10
var axis_max_value: float = 1.0
var action_toggle_state_map: Dictionary = {}

func get_mouse_wheel_axis(negative_action: StringName, positive_action: StringName) -> float:
	var axis_value: float = 0

	if EnhancedInputMap.action_has_mouse_wheel_event(negative_action) and Input.is_action_just_pressed(negative_action):
		axis_value -= axis_max_value

	if EnhancedInputMap.action_has_mouse_wheel_event(positive_action) and Input.is_action_just_pressed(positive_action):
		axis_value += axis_max_value

	return axis_value

func get_mouse_motion_axis(negative_action: StringName, positive_action: StringName) -> float:
	return get_action_mouse_motion(positive_action) - get_action_mouse_motion(negative_action)


func get_axis(negative_action: StringName, positive_action: StringName) -> float:
	var wheel_axis = get_mouse_wheel_axis(negative_action, positive_action)
	var mouse_axis = get_mouse_motion_axis(negative_action, positive_action)
	var multiplier = EnhancedInputMap.get_axis_multiplier(negative_action, positive_action)

	var togglable_axis_strength := get_action_strength(positive_action) - get_action_strength(negative_action)
	return multiplier * clampf(togglable_axis_strength + wheel_axis + mouse_axis, -axis_max_value, axis_max_value)

func is_action_just_pressed(action: StringName, exact_match: bool = false) -> bool:
	if is_toggled(action):
		return axis_max_value

	return Input.is_action_just_pressed(action, exact_match)



func get_action_strength(action: StringName, exact_match: bool = false) -> float:
	if is_toggled(action):
		return axis_max_value

	return Input.get_action_strength(action, exact_match)

func is_toggled(action: StringName) -> bool:
	return EnhancedInputMap.get_togglable(action) and action_toggle_state_map.get(action, false)

func switch_toggled(action: StringName) -> void:
	action_toggle_state_map[action] = not action_toggle_state_map.get(action, false)

func reset_toggle_state(action:  StringName) -> void:
	action_toggle_state_map[action] = false


func is_joy_motion_in_deadzone(action: StringName, event: InputEvent):
	return event is InputEventJoypadMotion and absf(event.axis_value) < InputMap.action_get_deadzone(action)

func start_joy_vibration(device: int, weak_magnitude: float, strong_magnitude: float, duration: float = 0) -> void:
	Input.start_joy_vibration(device, weak_magnitude * EnhancedInputMap.get_vibration_strength(), strong_magnitude * EnhancedInputMap.get_vibration_strength(), duration)

func get_vector(negative_x: StringName, positive_x: StringName, negative_y: StringName, positive_y: StringName, deadzone: float = -1.0) -> Vector2:
	var x_multiplier := EnhancedInputMap.get_axis_multiplier(negative_x, positive_x)
	var y_multiplier := EnhancedInputMap.get_axis_multiplier(negative_y, positive_y)

	var toggle_vector := Vector2(
			int(is_toggled(positive_x)) - int(is_toggled(negative_x)),
			int(is_toggled(positive_y)) - int(is_toggled(negative_y))
	)

	var vector = Input.get_vector(negative_x, positive_x, negative_y, positive_y, deadzone)
	vector.x += get_mouse_wheel_axis(negative_x, positive_x)
	vector.y += get_mouse_wheel_axis(negative_y, positive_y)
	vector.x += get_mouse_motion_axis(negative_x, positive_x)
	vector.y += get_mouse_motion_axis(negative_y, positive_y)
	vector += toggle_vector
	vector = vector.normalized()
	vector.x *= x_multiplier * mouse_velocity.x
	vector.y *= y_multiplier * mouse_velocity.y

	return vector


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.relative.length() > 1:
		var x := remap(event.relative.x, -mouse_motion_relative_max, mouse_motion_relative_max, -axis_max_value, axis_max_value)
		var y := remap(event.relative.y, -mouse_motion_relative_max, mouse_motion_relative_max, -axis_max_value, axis_max_value)
		x = clampf(x, -axis_max_value, axis_max_value)
		y = clampf(y, -axis_max_value, axis_max_value)


		if not limit_mouse_motion and event.velocity.length() >= Vector2.ONE.length():
			var reduced_velocity = event.velocity.abs() / mouse_velocity_reduction_scale
			mouse_velocity = reduced_velocity if reduced_velocity.length() >= Vector2.ONE.length() else Vector2.ONE
			print(event.velocity)

		mouse_motion = Vector2(x, y)
	elif event.is_match(EnhancedInputMap.wheel_down):
		mouse_wheel_counters[EnhancedInputMap.wheel_down] = mouse_wheel_counters.get_or_add(EnhancedInputMap.wheel_down, 0) + 1
	elif event.is_match(EnhancedInputMap.wheel_up):
		mouse_wheel_counters[EnhancedInputMap.wheel_up] = mouse_wheel_counters.get_or_add(EnhancedInputMap.wheel_up, 0) + 1


	var actions := EnhancedInputMap.get_actions_by_event(event)
	for action in actions:
		if EnhancedInputMap.get_togglable(action):
			if event.is_match(EnhancedInputMap.wheel_down):
				if mouse_wheel_counters[EnhancedInputMap.wheel_down] % 2 == 1:
					switch_toggled(action)
			elif event.is_match(EnhancedInputMap.wheel_up):
				if mouse_wheel_counters[EnhancedInputMap.wheel_up] % 2 == 1:
					switch_toggled(action)
			else:
				switch_toggled(action)
	call_deferred("_reset_mouse_motion")

func _reset_mouse_motion() -> void:
	mouse_motion = Vector2.ZERO
	mouse_velocity = Vector2.ONE


func filter_mouse_motion(e) -> bool:
	return e is InputEventMouseMotion and EnhancedInputMap.are_relative_directions_same(e.relative, mouse_motion)

func get_action_mouse_motion(action: StringName) -> float:
	var events := EnhancedInputMap.get_action_data(action).events.filter(filter_mouse_motion)

	if events.size() == 0:
		return 0

	var value: float = 0.0

	for e in events:
		var axis_index := EnhancedInputMap.get_more_significant_axis(e.relative)
		value += abs(mouse_motion[axis_index])

	return minf(value, axis_max_value)

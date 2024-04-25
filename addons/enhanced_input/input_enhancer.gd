#class_name InputEnhancer
extends Node

static var mouse_motion: Vector2


static var action_toggle_state_map: Dictionary = {}

static func get_mouse_wheel_axis(negative_action: StringName, positive_action: StringName) -> float:
	var axis_value: float = 0

	if EnhancedInputMap.action_has_mouse_wheel_event(negative_action) and Input.is_action_just_pressed(negative_action):
		axis_value -= 1

	if EnhancedInputMap.action_has_mouse_wheel_event(positive_action) and Input.is_action_just_pressed(positive_action):
		axis_value += 1

	return axis_value

static func get_mouse_motion_axis(negative_action: StringName, positive_action: StringName) -> float:
	return get_action_mouse_motion(positive_action) - get_action_mouse_motion(negative_action)

#static func get_mouse_motion_action(action: StringName)



static func get_axis(negative_action: StringName, positive_action: StringName) -> float:
	var wheel_axis = get_mouse_wheel_axis(negative_action, positive_action)
	var mouse_axis = get_mouse_motion_axis(negative_action, positive_action)
	var multiplier = EnhancedInputMap.get_axis_multiplier(negative_action, positive_action)

	var togglable_axis_strength := get_action_strength(positive_action) - get_action_strength(negative_action)
	return multiplier * clampf(togglable_axis_strength + wheel_axis + mouse_axis, -1.0, 1.0)

static func get_action_strength(action: StringName, exact_match: bool = false) -> float:
	if Input.is_action_just_pressed(action) and EnhancedInputMap.get_togglable(action):
		action_toggle_state_map[action] = not action_toggle_state_map.get(action, false)

	if EnhancedInputMap.get_togglable(action) and action_toggle_state_map.get(action, false):
		return 1
	else:
		return Input.get_action_strength(action, exact_match)



static func reset_toggle_state(action:  StringName) -> void:
	action_toggle_state_map[action] = false




static func is_joy_motion_in_deadzone(action: StringName, event: InputEvent):
	return event is InputEventJoypadMotion and absf(event.axis_value) < InputMap.action_get_deadzone(action)

static func start_joy_vibration(device: int, weak_magnitude: float, strong_magnitude: float, duration: float = 0) -> void:
	Input.start_joy_vibration(device, weak_magnitude * EnhancedInputMap.get_vibration_strength(), strong_magnitude * EnhancedInputMap.get_vibration_strength(), duration)

static func get_vector(negative_x: StringName, positive_x: StringName, negative_y: StringName, positive_y: StringName, deadzone: float = -1.0) -> Vector2:
	# TODO think about better implementation
	#var x := get_axis(negative_x, positive_x)
	#var y := get_axis(negative_y, positive_y)
	var x_multiplier := EnhancedInputMap.get_axis_multiplier(negative_x, positive_x)
	var y_multiplier := EnhancedInputMap.get_axis_multiplier(negative_y, positive_y)

	# TODO: Handle mousemove
	# TODO: Handle togglable
	# TODO: Fix issue with sensitivity 0
	var vector = Input.get_vector(negative_x, positive_x, negative_y, positive_y, deadzone)
	vector.x += get_mouse_wheel_axis(negative_x, positive_x)
	vector.y += get_mouse_wheel_axis(negative_y, positive_y)
	vector.x += get_mouse_motion_axis(negative_x, positive_x)
	vector.y += get_mouse_motion_axis(negative_y, positive_y)
	vector.x *= x_multiplier
	vector.y *= y_multiplier

	return vector


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.relative.length() > 1:
		var x := clampf(remap(event.relative.x, -10, 10, -1, 1), -1, 1)
		var y := clampf(remap(event.relative.y, -10, 10, -1, 1), -1, 1)

		mouse_motion = Vector2(x, y)

	call_deferred("_reset_mouse_motion")

func _reset_mouse_motion() -> void:
	mouse_motion = Vector2.ZERO


static func filter_mouse_motion(e) -> bool:
	print(InputEnhancer.mouse_motion)
	if e is InputEventMouseMotion:
		var axis_index := -1
		if abs(e.relative.x) > abs(e.relative.y):
			axis_index = Vector2.AXIS_X
		else:
			axis_index = Vector2.AXIS_Y

		if not is_equal_approx(mouse_motion[axis_index], 0):
			if is_equal_approx(signf(e.relative[axis_index]), signf(mouse_motion[axis_index])):
				return true

	return false

static func get_action_mouse_motion(action: StringName) -> float:
	var events := EnhancedInputMap.get_action_data(action).events.filter(filter_mouse_motion
	)

	if events.size() == 0:
		return 0

	var value: float = 0.0

	for e in events:
		var axis_index := -1
		if abs(e.relative.x) > abs(e.relative.y):
			axis_index = Vector2.AXIS_X
		else:
			axis_index = Vector2.AXIS_Y

		value += abs(mouse_motion[axis_index])
	return minf(value, 1.0)

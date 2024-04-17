#class_name InputEnhancer
extends Node

static var loaded_signal_holder := LoadedSignalHolder.new()
static var saved_path := "user://input_map_scheme.tres"
static var default_path := "res://default_input_map_scheme.tres"
static var pairs := [
	{"negative": "_left", "positive": "_right"},
	{"negative": "_up", "positive": "_down"},
	{"negative": "_forward", "positive": "_back"},
]
static var mouse_motion: Vector2

static var mouse_motion_default_events := {
	"camera_rotate_up": _create_mouse_motioon(Vector2.AXIS_Y, -1),
	"camera_rotate_down": _create_mouse_motioon(Vector2.AXIS_Y, 1),
	"camera_rotate_left": _create_mouse_motioon(Vector2.AXIS_X, -1),
	"camera_rotate_right": _create_mouse_motioon(Vector2.AXIS_X, 1),
}

static func _create_mouse_motioon(axis_index: int, value: int) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.relative[axis_index] = value

	return event

static var wheel_down: InputEventMouseButton
static var wheel_up: InputEventMouseButton
static var action_toggle_state_map: Dictionary = {}
static var input_scheme : InputMapScheme

static var loaded: Signal:
	get:
		return loaded_signal_holder.loaded

static func get_mouse_wheel_axis(negative_action: StringName, positive_action: StringName) -> float:
	var axis_value: float = 0

	if action_has_mouse_wheel_event(negative_action) and Input.is_action_just_pressed(negative_action):
		axis_value -= 1

	if action_has_mouse_wheel_event(positive_action) and Input.is_action_just_pressed(positive_action):
		axis_value += 1

	return axis_value

static func get_mouse_motion_axis(negative_action: StringName, positive_action: StringName) -> float:
	return get_action_mouse_motion(positive_action) - get_action_mouse_motion(negative_action)

#static func get_mouse_motion_action(action: StringName)

static func get_axis_multiplier(negative_action: StringName, positive_action: StringName) -> float:
	var axis_data = input_scheme.get_axis_data(negative_action, positive_action)
	var multiplier = 1 if not axis_data \
			else axis_data.sensitivity.value \
			* (-1 if axis_data.is_inverted.value else 1)

	return multiplier

static func get_axis(negative_action: StringName, positive_action: StringName) -> float:
	var wheel_axis = get_mouse_wheel_axis(negative_action, positive_action)
	var mouse_axis = get_mouse_motion_axis(negative_action, positive_action)
	var multiplier = get_axis_multiplier(negative_action, positive_action)

	var togglable_axis_strength := get_action_strength(positive_action) - get_action_strength(negative_action)
	return multiplier * clampf(togglable_axis_strength + wheel_axis + mouse_axis, -1.0, 1.0)

static func get_action_strength(action: StringName, exact_match: bool = false) -> float:
	if Input.is_action_just_pressed(action) and get_togglable(action):
		action_toggle_state_map[action] = not action_toggle_state_map.get(action, false)

	if get_togglable(action) and action_toggle_state_map.get(action, false):
		return 1
	else:
		return Input.get_action_strength(action, exact_match)

static func action_has_mouse_wheel_event(action_name: StringName):
	if not wheel_down:
		wheel_down = InputEventMouseButton.new()
		wheel_down.button_index = MOUSE_BUTTON_WHEEL_DOWN

	if not wheel_up:
		wheel_up = InputEventMouseButton.new()
		wheel_up.button_index = MOUSE_BUTTON_WHEEL_UP

	return (InputMap.action_has_event(action_name, wheel_down) \
		or InputMap.action_has_event(action_name, wheel_up))

static func get_togglable(action: StringName) -> bool:
	var action_data = input_scheme.get_action_data(action)
	return action_data.is_togglable if action_data else false

static func set_togglable(action: StringName, state: bool):
	input_scheme.set_action_togglable(action, state)
	action_toggle_state_map[action] = false
	#save_current_scheme()

static func set_deadzone(action: StringName, value: float) -> void:
	InputMap.action_set_deadzone(action, value)
	input_scheme.set_action_deadzone(action, value)
	#save_current_scheme()

static func get_action_data(action: StringName) -> InputMapActionData:
	return input_scheme.get_action_data(action)


static func save_current_scheme() -> void:
	ResourceSaver.save(input_scheme, saved_path)

static func save_default_scheme() -> void:
	var all_actions := InputMap.get_actions()
	var input_map_scheme = InputMapScheme.new()

	var axes: Dictionary = {}

	for action in all_actions:
		if action.begins_with("ui_"):
			continue
		var action_data := InputMapActionData.new()
		action_data.action = action
		action_data.deadzone = InputMap.action_get_deadzone(action)

		var all_events := InputMap.action_get_events(action)
		action_data.events.append_array(all_events)
		if mouse_motion_default_events.has(action):
			action_data.events.append(mouse_motion_default_events[action])

		input_map_scheme.actions.append(action_data)

		for pair in pairs:
			if action.ends_with(pair.negative):
				var axis_other_end := action.replace(pair.negative, pair.positive)
				if not axes.has(axis_other_end):
					axes[action] = InputAxisData.new()
					axes[action].negative_action = action
				else:
					axes[axis_other_end].negative_action = action
			elif action.ends_with(pair.positive):
					var axis_other_end := action.replace(pair.positive, pair.negative)
					if not axes.has(axis_other_end):
						axes[action] = InputAxisData.new()
						axes[action].positive_action = action
					else:
						axes[axis_other_end].positive_action = action

	for axis in axes:
		input_map_scheme.add_axis(axes[axis])

	ResourceSaver.save(input_map_scheme, default_path)

static func reset_input_scheme() -> void:
	if FileAccess.file_exists(saved_path):
		DirAccess.remove_absolute(saved_path)

	load_input_scheme()

static func load_input_scheme() -> void:
	if FileAccess.file_exists(saved_path):
		input_scheme = InputMapScheme.load(saved_path)
		print("saved")
	else:
		print("default")
		if not FileAccess.file_exists(default_path):
			print("create default")
			save_default_scheme()
		input_scheme = InputMapScheme.load(default_path)

	for action_data in input_scheme.actions:
		var action := action_data.action
		if InputMap.has_action(action):
			InputMap.action_erase_events(action)
		else:
			InputMap.add_action(action)

		InputMap.action_set_deadzone(action, action_data.deadzone)
		for event in action_data.events:
			InputMap.action_add_event(action, event)

	input_scheme.changed.connect(save_current_scheme)
	loaded_signal_holder.loaded.emit()

static func replace_event(action: StringName, old_event: InputEvent, new_event: InputEvent):
	if old_event:
		InputMap.action_erase_event(action, old_event)
		input_scheme.remove_action_event(action, old_event)

	InputMap.action_add_event(action, new_event)
	input_scheme.add_action_event(action, new_event)
	#save_current_scheme()

static func is_joy_motion_in_deadzone(action: StringName, event: InputEvent):
	return event is InputEventJoypadMotion and absf(event.axis_value) < InputMap.action_get_deadzone(action)

static func action_erase_event(action: StringName, event: InputEvent) -> void:
	InputMap.action_erase_event(action, event)
	input_scheme.remove_action_event(action, event)
	#save_current_scheme()

static func start_joy_vibration(device: int, weak_magnitude: float, strong_magnitude: float, duration: float = 0) -> void:
	Input.start_joy_vibration(device, weak_magnitude * get_vibration_strength(), strong_magnitude * get_vibration_strength(), duration)

static func get_vibration_strength():
	return input_scheme.vibration_strength.value

static func get_vector(negative_x: StringName, positive_x: StringName, negative_y: StringName, positive_y: StringName, deadzone: float = -1.0) -> Vector2:
	# TODO think about better implementation
	#var x := get_axis(negative_x, positive_x)
	#var y := get_axis(negative_y, positive_y)
	var x_multiplier := get_axis_multiplier(negative_x, positive_x)
	var y_multiplier := get_axis_multiplier(negative_y, positive_y)

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
	var events := get_action_data(action).events.filter(filter_mouse_motion
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

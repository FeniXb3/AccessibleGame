class_name EnhancedInputMap


static var loaded_signal_holder := LoadedSignalHolder.new()
static var loaded: Signal:
	get:
		return loaded_signal_holder.loaded

static var saved_path := "user://input_map_scheme.tres"
static var default_path := "res://default_input_map_scheme.tres"
static var wheel_down: InputEventMouseButton:
	get:
		if not wheel_down:
			wheel_down = InputEventMouseButton.new()
			wheel_down.button_index = MOUSE_BUTTON_WHEEL_DOWN
		return wheel_down
static var wheel_up: InputEventMouseButton:
	get:
		if not wheel_up:
			wheel_up = InputEventMouseButton.new()
			wheel_up.button_index = MOUSE_BUTTON_WHEEL_UP
		return wheel_up
static var input_scheme : InputMapScheme
static var mouse_motion_default_events := {
	"camera_rotate_up": _create_mouse_motioon(Vector2.AXIS_Y, -1),
	"camera_rotate_down": _create_mouse_motioon(Vector2.AXIS_Y, 1),
	"rotate_left": _create_mouse_motioon(Vector2.AXIS_X, -1),
	"rotate_right": _create_mouse_motioon(Vector2.AXIS_X, 1),
}
static var pairs := [
	{"negative": "_left", "positive": "_right"},
	{"negative": "_up", "positive": "_down"},
	{"negative": "_forward", "positive": "_back"},
]

static func _create_mouse_motioon(axis_index: int, value: int) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.relative[axis_index] = value

	return event

static func replace_event(action: StringName, old_event: InputEvent, new_event: InputEvent):
	if old_event:
		InputMap.action_erase_event(action, old_event)
		input_scheme.remove_action_event(action, old_event)

	InputMap.action_add_event(action, new_event)
	input_scheme.add_action_event(action, new_event)

static func action_erase_event(action: StringName, event: InputEvent) -> void:
	InputMap.action_erase_event(action, event)
	input_scheme.remove_action_event(action, event)

static func get_vibration_strength():
	return input_scheme.vibration_strength.value

static func action_has_mouse_wheel_event(action_name: StringName):
	return (InputMap.action_has_event(action_name, wheel_down) \
		or InputMap.action_has_event(action_name, wheel_up))

static func get_axis_multiplier(negative_action: StringName, positive_action: StringName) -> float:
	var axis_data = input_scheme.get_axis_data(negative_action, positive_action)
	var multiplier = 1 if not axis_data \
			else axis_data.sensitivity.value \
			* (-1 if axis_data.is_inverted.value else 1)

	return multiplier


static func get_togglable(action: StringName) -> bool:
	var action_data = input_scheme.get_action_data(action)
	return action_data.is_togglable if action_data else false

static func set_togglable(action: StringName, state: bool):
	input_scheme.set_action_togglable(action, state)


static func set_deadzone(action: StringName, value: float) -> void:
	InputMap.action_set_deadzone(action, value)
	input_scheme.set_action_deadzone(action, value)

static func get_action_data(action: StringName) -> InputMapActionData:
	return input_scheme.get_action_data(action)


static func save_current_scheme() -> void:
	ResourceSaver.save(input_scheme, saved_path)

static func reset_input_scheme() -> void:
	if FileAccess.file_exists(saved_path):
		DirAccess.remove_absolute(saved_path)

	load_input_scheme()


static func load_input_scheme() -> void:
	if FileAccess.file_exists(saved_path):
		input_scheme = InputMapScheme.load(saved_path)
	else:
		if not FileAccess.file_exists(default_path):
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

static func are_relative_directions_same(relative, other_relative):
	var axis_index := get_more_significant_axis(relative)

	if is_equal_approx(other_relative[axis_index], 0):
		return false

	return is_equal_approx(signf(relative[axis_index]), signf(other_relative[axis_index]))


static func get_more_significant_axis(vector: Vector2) -> float:
	return Vector2.AXIS_X if abs(vector.x) > abs(vector.y) else Vector2.AXIS_Y

static func get_actions_by_event(event: InputEvent) -> Array[String]:
	var actions: Array[String] = []

	for action_data in input_scheme.actions:
		for e in action_data.events:
			if e.get_class() == event.get_class() and are_good_enough(e, event, action_data.action):
				actions.append(action_data.action)

	return actions

static func are_good_enough(e: InputEvent, event: InputEvent, action: StringName):
	if event is InputEventMouseMotion:
		return are_relative_directions_same(e.relative, event.relative)
	else:
		return e.is_match(event) and Input.is_action_just_pressed(action)


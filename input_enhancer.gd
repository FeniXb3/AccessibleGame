class_name InputEnhancer

static var loaded_signal_holder := LoadedSignalHolder.new()
static var saved_path := "user://input_map_scheme.tres"
static var default_path := "res://default_input_map_scheme.tres"

static var wheel_down: InputEventMouseButton
static var wheel_up: InputEventMouseButton
static var action_togglable_map: Dictionary = {}
static var action_toggle_state_map: Dictionary = {}
static var input_scheme : InputMapScheme#.new()

static var loaded: Signal:
	get:
		return loaded_signal_holder.loaded

static func get_axis_or_mouse_wheel(negative_action: StringName, positive_action: StringName) -> float:
	var axis_value: float = 0

	if action_has_mouse_wheel_event(negative_action) and Input.is_action_just_pressed(negative_action):
		axis_value -= 1

	if action_has_mouse_wheel_event(positive_action) and Input.is_action_just_pressed(positive_action):
		axis_value += 1

	return get_axis(negative_action, positive_action) + axis_value

static func get_axis(negative_action: StringName, positive_action: StringName) -> float:
	return get_action_strength(positive_action) - get_action_strength(negative_action)

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
	#return action_togglable_map.get(action, false)

static func set_togglable(action: StringName, state: bool):
	input_scheme.set_action_togglable(action, state)
	action_toggle_state_map[action] = false
	save_current_scheme()

static func get_action_data(action: StringName) -> InputMapActionData:
	return input_scheme.get_action_data(action)

static func save_current_scheme() -> void:
	ResourceSaver.save(input_scheme, saved_path)

static func save_default_scheme() -> void:
	var all_actions := InputMap.get_actions()
	var input_map_scheme = InputMapScheme.new()

	for action in all_actions:
		if action.begins_with("ui_"):
			continue
		var action_data := InputMapActionData.new()
		action_data.action = action

		var all_events := InputMap.action_get_events(action)
		action_data.events.append_array(all_events)
		input_map_scheme.actions.append(action_data)

	ResourceSaver.save(input_map_scheme, default_path)

static func load_input_scheme() -> void:
	if FileAccess.file_exists(saved_path):
		input_scheme = ResourceLoader.load(saved_path, "InputMapScheme")
		print("saved")
	else:
		print("default")
		if not FileAccess.file_exists(default_path):
			print("create default")
			save_default_scheme()
		input_scheme = ResourceLoader.load(default_path, "InputMapScheme").duplicate(true)

	for action_data in input_scheme.actions:
		var action := action_data.action
		if InputMap.has_action(action):
			InputMap.action_erase_events(action)
		else:
			InputMap.add_action(action)

		for event in action_data.events:
			InputMap.action_add_event(action, event)

	loaded_signal_holder.loaded.emit()

static func replace_event(action: StringName, old_event: InputEvent, new_event: InputEvent):
	if old_event:
		InputMap.action_erase_event(action, old_event)
		input_scheme.remove_action_event(action, old_event)

	InputMap.action_add_event(action, new_event)
	input_scheme.add_action_event(action, new_event)
	save_current_scheme()

static func is_joy_motion_in_deadzone(action: StringName, event: InputEvent):
	return event is InputEventJoypadMotion and absf(event.axis_value) < InputMap.action_get_deadzone(action)

static func action_erase_event(action: StringName, event: InputEvent) -> void:
	InputMap.action_erase_event(action, event)
	input_scheme.remove_action_event(action, event)
	save_current_scheme()

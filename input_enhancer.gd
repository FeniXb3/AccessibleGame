class_name InputEnhancer

static var wheel_down: InputEventMouseButton
static var wheel_up: InputEventMouseButton
static var action_togglable_map: Dictionary = {}
static var action_toggle_state_map: Dictionary = {}

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
	
	if action_togglable_map.get(action, false) and action_toggle_state_map.get(action, false):
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
	return action_togglable_map.get(action, false)

static func set_togglable(action: StringName, state: bool):
	action_togglable_map[action] = state
	action_toggle_state_map[action] = false

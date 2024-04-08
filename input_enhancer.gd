class_name InputEnhancer

static var wheel_down: InputEventMouseButton

static var wheel_up: InputEventMouseButton

static func get_axis_or_mouse_wheel(negative_action: StringName, positive_action: StringName) -> float:
	var axis_value: float = 0
	
	if action_has_mouse_wheel_event(negative_action) and Input.is_action_just_pressed(negative_action):
		axis_value -= 1
	
	if action_has_mouse_wheel_event(positive_action) and Input.is_action_just_pressed(positive_action):
		axis_value += 1
	
	return Input.get_axis(negative_action, positive_action) + axis_value

static func action_has_mouse_wheel_event(action_name: StringName):
	if not wheel_down:
		wheel_down = InputEventMouseButton.new()
		wheel_down.button_index = MOUSE_BUTTON_WHEEL_DOWN
	
	if not wheel_up:
		wheel_up = InputEventMouseButton.new()
		wheel_up.button_index = MOUSE_BUTTON_WHEEL_UP
	
	return (InputMap.action_has_event(action_name, wheel_down) \
		or InputMap.action_has_event(action_name, wheel_up))

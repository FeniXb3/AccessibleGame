extends Resource
class_name InputMapScheme


@export var actions: Array[InputMapActionData] = []
@export var vibration_strength: FloatVariable = FloatVariable.new(1)
@export var axes: Array[InputAxisData] = []

static func load(path: String) -> InputMapScheme:
	var scheme := ResourceLoader.load(path, "InputMapScheme", ResourceLoader.CACHE_MODE_IGNORE) as InputMapScheme

	scheme._connect_sub_resources()

	return scheme

func _connect_sub_resources() -> void:
	vibration_strength.changed.connect(emit_changed)
	for action_data in actions:
		action_data.changed.connect(emit_changed)

	for axis in axes:
		axis.connect_sub_resources()
		axis.changed.connect(emit_changed)

func add_axis(axis: InputAxisData) -> void:
	axis.changed.connect(emit_changed)
	axes.append(axis)

func get_axis_data(negative_action: StringName, positive_action: StringName) -> InputAxisData:
	var filtered := axes.filter(func(iad): return iad.negative_action == negative_action and iad.positive_action == positive_action)
	return filtered.front() if filtered else null

func get_action_data(action: StringName) -> InputMapActionData:
	var data = actions.filter(func(ad: InputMapActionData): return ad.action == action)
	return data.front() if data else null

func get_action_togglable(action: StringName) -> bool:
	var action_data = get_action_data(action)
	return action_data.is_togglable if action_data else false

func set_action_togglable(action: StringName, is_togglable: bool) -> void:
	var action_data = get_action_data(action)
	if action_data:
		action_data.is_togglable = is_togglable

func set_action_deadzone(action: StringName, value: float):
	var action_data = get_action_data(action)
	if action_data:
		action_data.deadzone = value

func add_action_event(action: StringName, event: InputEvent) -> void:
	var action_data := get_action_data(action)
	if action_data:
		if not action_data.has_event(event):
			action_data.add_event(event)
		else:
			print("Event already there")


func remove_action_event(action: StringName, event: InputEvent) -> void:
	var action_data := get_action_data(action)
	if action_data:
		if action_data.has_event(event):
			action_data.remove_event(event)
		else:
			print("Event not there")

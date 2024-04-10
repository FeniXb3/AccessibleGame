extends Resource
class_name InputMapScheme

@export var actions: Array[InputMapActionData] = []

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
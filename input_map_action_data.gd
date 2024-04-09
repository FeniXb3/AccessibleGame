extends Resource
class_name InputMapActionData

signal togglable_changed(new_value : bool)

#TODO handle deadzone getting and setting; display it only if action has joypad motion
@export var action: StringName
@export var is_togglable: bool = false:
	set(new_value):
		if not is_togglable == new_value:
			is_togglable = new_value
			togglable_changed.emit(is_togglable)
@export var events: Array[InputEvent] = []

func has_event(event: InputEvent) -> bool:
	return events.any(func(e: InputEvent): return e == event)

func add_event(event: InputEvent) -> void:
	events.append(event)

func remove_event(event: InputEvent) -> void:
	events.erase(event)

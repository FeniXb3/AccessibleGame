extends Resource
class_name ColorVariable

signal value_changed(new_value : Color)

@export var value : Color:
	set(new_value):
		if not value == new_value:
			value = new_value
			value_changed.emit(value)

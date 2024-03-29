extends Resource
class_name FloatVariable

signal value_changed(new_value : float)

@export var value : float:
	set(new_value):
		if not value == new_value:
			value = new_value
			value_changed.emit(value)

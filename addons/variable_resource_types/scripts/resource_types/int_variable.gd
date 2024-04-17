extends Resource
class_name IntVariable

signal value_changed(new_value : int)

@export var value : int:
	set(new_value):
		if not value == new_value:
			value = new_value
			value_changed.emit(value)

extends Resource
class_name BoolVariable

signal value_changed(new_value : bool)

@export var value : bool:
	set(new_value):
		if not value == new_value:
			value = new_value
			value_changed.emit(value)

extends Resource
class_name StringVariable

signal value_changed(new_value : String)

@export var value : String:
	set(new_value):
		if not value == new_value:
			value = new_value
			value_changed.emit(value)

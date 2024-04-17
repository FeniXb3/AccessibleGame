extends Resource
class_name Vector2Variable

signal value_changed(new_value : Vector2)

@export var value : Vector2:
	set(new_value):
		if not value == new_value:
			value = new_value
			value_changed.emit(value)

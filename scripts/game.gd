extends Node

@onready var options_container = %OptionsContainer


func _ready():
	EnhancedInputMap.load_input_scheme()
	options_container.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(_event : InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		options_container.visible = not options_container.visible
		get_tree().paused = options_container.visible

		if get_tree().paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

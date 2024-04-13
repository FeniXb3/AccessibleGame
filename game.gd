extends Node

@onready var options_container = %OptionsContainer


func _ready():
	InputEnhancer.load_input_scheme()
	options_container.hide()

func _input(_event : InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		options_container.visible = not options_container.visible
		get_tree().paused = options_container.visible

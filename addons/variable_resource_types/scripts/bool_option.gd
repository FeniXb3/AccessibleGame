class_name BoolOption
extends HBoxContainer

@export var label_text: String
@export var variable : BoolVariable:
	set(value):
		if variable != value:
			variable = value
			setup()

@onready var value_check_button: CheckButton = %ValueCheckButton

func _ready():
	if variable:
		setup()

func setup():
	value_check_button.button_pressed = variable.value
	value_check_button.text = label_text
	variable.value_changed.connect(_on_value_changed)


func _on_value_changed(new_value : bool) -> void:
	value_check_button.button_pressed  = new_value


func _on_value_check_button_toggled(toggled_on: bool) -> void:
	variable.value = toggled_on

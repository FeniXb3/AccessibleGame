extends HBoxContainer

@export var color_label_text : String
@export var color_variable : ColorVariable

@onready var color_label = %ColorLabel
@onready var color_picker_button = %ColorPickerButton

func _ready():
	color_label.text = color_label_text
	color_variable.value_changed.connect(_on_color_variable_value_changed)

func _on_color_variable_value_changed(new_value : Color):
	color_picker_button.color = new_value
	


func _on_color_picker_button_color_changed(color):
	color_variable.value = color

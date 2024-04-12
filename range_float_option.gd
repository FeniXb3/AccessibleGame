class_name RangeFloatOption
extends HBoxContainer

@export var label_text : String
@export var variable : FloatVariable:
	set(value):
		if variable != value:
			variable = value
			setup()
@export var min_value : float = 0
@export var max_value : float = 1
@export var step := 0.1

@onready var label = %Label
@onready var range_slider = %RangeSlider
@onready var value_label = %ValueLabel

func _ready():
	if variable:
		setup()

func setup():
	label.text = label_text
	range_slider.min_value = min_value
	range_slider.max_value = max_value
	range_slider.step = step
	range_slider.value = variable.value
	variable.value_changed.connect(_on_value_changed)
	value_label.text = "%.2f" % range_slider.value


func _on_value_changed(new_value : float) -> void:
	range_slider.value = new_value
	value_label.text = "%.2f" % new_value


func _on_range_slider_value_changed(value : float) -> void:
	variable.value = value
	value_label.text = "%.2f" % value

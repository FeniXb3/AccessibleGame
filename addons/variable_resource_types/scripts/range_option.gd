extends HBoxContainer

@export var label_text : String
@export var variable : IntVariable
@export var min_value : int
@export var max_value : int
@export var step := 1

@onready var label = %Label
@onready var range_slider = %RangeSlider
@onready var value_label = %ValueLabel

func _ready():
	label.text = label_text
	variable.value_changed.connect(_on_value_changed)
	range_slider.min_value = min_value
	range_slider.max_value = max_value
	range_slider.step = step
	value_label.text = "%d" % range_slider.value
	

func _on_value_changed(new_value : int) -> void:
	range_slider.value = new_value
	value_label.text = "%d" % new_value
	

func _on_range_slider_value_changed(value : int) -> void:
	variable.value = value
	value_label.text = "%d" % value

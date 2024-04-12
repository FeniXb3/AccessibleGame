class_name AxisDataOption
extends HBoxContainer

@export var axis_data: InputAxisData

@onready var axis_name_label: Label = %AxisNameLabel
@onready var sensitivity_option: RangeFloatOption = %SensitivityOption
@onready var is_inverted_option: BoolOption = %IsInvertedOption

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	axis_name_label.text = "%s-%s" % [axis_data.negative_action, axis_data.positive_action]
	sensitivity_option.variable = axis_data.sensitivity
	is_inverted_option.variable = axis_data.is_inverted


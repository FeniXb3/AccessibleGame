class_name InputAxisData
extends Resource

@export var negative_action: StringName
@export var positive_action: StringName
@export var sensitivity: FloatVariable = FloatVariable.new(1)
@export var is_inverted: BoolVariable = BoolVariable.new()

func connect_sub_resources() -> void:
	sensitivity.changed.connect(emit_changed)
	is_inverted.changed.connect(emit_changed)

extends PanelContainer

@export var single_option_scene : PackedScene

@onready var keyboard_controls_parent = %KeyboardControlsParent
@onready var mouse_controls_parent = %MouseControlsParent
@onready var joy_controls_parent = %JoyControlsParent
@onready var controls_parents = {
		ActionRemapButton.RemapEventType.KEYBOARD: keyboard_controls_parent,
		ActionRemapButton.RemapEventType.MOUSE: mouse_controls_parent,
		ActionRemapButton.RemapEventType.JOY: joy_controls_parent
	}

func _ready():
	InputEnhancer.loaded.connect(_on_input_scheme_loaded)


func _on_input_scheme_loaded():
	for action_data in InputEnhancer.input_scheme.actions:
		if action_data.events.is_empty():
			continue

		for remap_filter in controls_parents:
			var new_control_option := single_option_scene.instantiate() as ControlOption
			new_control_option.action = action_data.action
			new_control_option.remap_type_filter = remap_filter
			controls_parents[remap_filter].add_child(new_control_option)
			controls_parents[remap_filter].add_child(HSeparator.new())


func _on_reset_input_scheme_button_pressed():
	for remap_filter in controls_parents:
		for i in controls_parents[remap_filter].get_child_count():
			for child in controls_parents[remap_filter].get_children():
				child.queue_free()

	call_deferred("_reset_input_scheme")

func _reset_input_scheme():
	InputEnhancer.reset_input_scheme()

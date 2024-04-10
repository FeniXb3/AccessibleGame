extends PanelContainer

@export var single_option_scene : PackedScene

#@onready var controls_parent = %ControlsParent
@onready var keyboard_controls_parent = %KeyboardControlsParent
@onready var mouse_controls_parent = %MouseControlsParent
@onready var joy_controls_parent = %JoyControlsParent

func _ready():
	InputEnhancer.loaded.connect(_on_input_scheme_loaded)


func _on_input_scheme_loaded():
	var controls_parents = {
		ActionRemapButton.RemapEventType.KEYBOARD: keyboard_controls_parent,
		ActionRemapButton.RemapEventType.MOUSE: mouse_controls_parent,
		ActionRemapButton.RemapEventType.JOY: joy_controls_parent
	}
#todo use enhancer
	var all_actions := InputMap.get_actions()
	for action in all_actions:
		if action.begins_with("ui_"):
			continue

		var events := InputMap.action_get_events(action)
		if events.is_empty():
			continue

		for remap_filter in controls_parents:
			var new_control_option := single_option_scene.instantiate() as ControlOption
			new_control_option.action = action
			new_control_option.remap_type_filter = remap_filter
			controls_parents[remap_filter].add_child(new_control_option)
			controls_parents[remap_filter].add_child(HSeparator.new())

extends PanelContainer

@export var single_option_scene : PackedScene

@onready var controls_parent = %ControlsParent

# Called when the node enters the scene tree for the first time.
func _ready():
	var all_actions := InputMap.get_actions()
	for action in all_actions:
		if not action.begins_with("ui_"):
			var events := InputMap.action_get_events(action)
			print("{action} : {events}".format({"action":action, "events":events}))
			if events.is_empty():
				continue
				
			var new_control_option := single_option_scene.instantiate() as ControlOption
			new_control_option.action = action
			new_control_option.events = events
			controls_parent.add_child(new_control_option)
			controls_parent.add_child(HSeparator.new())

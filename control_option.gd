extends HBoxContainer
class_name ControlOption

@export var action : String
@export var remap_type_filter : ActionRemapButton.RemapEventType
@export var action_remap_button_scene : PackedScene

@onready var label = %Label
@onready var keyboard_action_remap_button : ActionRemapButton = %KeyboardActionRemapButton
@onready var mouse_action_remap_button : ActionRemapButton = %MouseActionRemapButton
@onready var joy_action_remap_button : ActionRemapButton = %JoyActionRemapButton
@onready var action_events_container = %ActionEventsContainer

var consume_input : bool
var events : Array[InputEvent]

func _ready():
	label.text = action
	events = InputMap.action_get_events(action)
	
	keyboard_action_remap_button.setup(action, events, remap_type_filter)
	#mouse_action_remap_button.setup(action, events, remap_type_filter)
	#joy_action_remap_button.setup(action, events, remap_type_filter)

func focus_button():
	keyboard_action_remap_button.grab_focus()

func _on_add_action_event_pressed():
	var new_action_remap_button : ActionRemapButton = action_remap_button_scene.instantiate()
	new_action_remap_button.setup(action, events, remap_type_filter, action_events_container.get_child_count())
	action_events_container.add_child(new_action_remap_button)
	new_action_remap_button.grab_focus()
	new_action_remap_button.pressed.emit()

extends HBoxContainer
class_name ControlOption

@export var action : String
@export var remap_type_filter : ActionRemapButton.RemapEventType
@export var action_remap_button_scene : PackedScene

@onready var label = %Label
@onready var action_events_container = %ActionEventsContainer
@onready var add_action_event = %AddActionEvent

var consume_input : bool
var events : Array[InputEvent]

func _ready():
	label.text = action
	events = InputMap.action_get_events(action).filter(_filter_events_by_type)
	
	for e in events:
		_add_button_with_event(e)

func _add_button_with_event(event: InputEvent):
	var new_action_remap_button : ActionRemapButton = action_remap_button_scene.instantiate()
	new_action_remap_button.setup(action, remap_type_filter, event)
	action_events_container.add_child(new_action_remap_button)
	
func _on_add_action_event_pressed():
	var new_action_remap_button : ActionRemapButton = action_remap_button_scene.instantiate()
	new_action_remap_button.setup(action, remap_type_filter, null)
	new_action_remap_button.empty_remap_canceled.connect(_on_empty_remap_canceled)
	action_events_container.add_child(new_action_remap_button)
	new_action_remap_button.grab_focus()
	new_action_remap_button.pressed.emit()

func _on_empty_remap_canceled (button_source):
	action_events_container.remove_child(button_source)
	button_source.queue_free()
	add_action_event.grab_focus()


func _filter_events_by_type(e: InputEvent):
	match remap_type_filter:
		ActionRemapButton.RemapEventType.KEYBOARD:
			return e is InputEventKey
		ActionRemapButton.RemapEventType.MOUSE:
			return e is InputEventMouse
		ActionRemapButton.RemapEventType.JOY:
			return e is InputEventJoypadButton or e is InputEventJoypadMotion
		ActionRemapButton.RemapEventType.ANY:
			return true

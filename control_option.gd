extends VBoxContainer
class_name ControlOption

@export var action : String
@export var remap_type_filter : ActionRemapButton.RemapEventType
@export var action_remap_button_scene : PackedScene
@export var remapping_row_scene : PackedScene
@export var action_data: InputMapActionData

@onready var label = %Label
@onready var action_events_container = %ActionEventsContainer
@onready var add_action_event = %AddActionEvent
@onready var is_toggle_check = %IsToggleCheck

var consume_input : bool
var events : Array[InputEvent]

func _ready():
	label.text = action
	action_data = InputEnhancer.get_action_data(action)
	action_data.togglable_changed.connect(_on_action_data_togglable_changed)
	events = InputMap.action_get_events(action).filter(_filter_events_by_type)
	is_toggle_check.button_pressed = action_data.is_togglable#InputEnhancer.get_togglable(action)

	for e in events:
		_add_button_with_event(e)
func _on_action_data_togglable_changed(new_value: bool) -> void:
	is_toggle_check.button_pressed = new_value

func _add_button_with_event(event: InputEvent):
	#var new_action_remap_button : ActionRemapButton = action_remap_button_scene.instantiate()
	#new_action_remap_button.setup(action, remap_type_filter, event)
	#action_events_container.add_child(new_action_remap_button)
	#
	_add_row(event)

func _add_row(event : InputEvent) -> RemappingRow:
	var new_row : RemappingRow = remapping_row_scene.instantiate()
	new_row.setup(action, remap_type_filter, event)
	new_row.get_child(1).empty_remap_canceled.connect(_on_empty_remap_canceled)
	new_row.remove_button_pressed.connect(_on_remove_button_pressed)
	action_events_container.add_child(new_row)
	return new_row

func _on_add_action_event_pressed():
	var new_row := _add_row(null)
	new_row.invoke_remapping()

func _on_add_action_event_pressed2():
	var new_action_remap_button : ActionRemapButton = action_remap_button_scene.instantiate()
	new_action_remap_button.setup(action, remap_type_filter, null)
	new_action_remap_button.empty_remap_canceled.connect(_on_empty_remap_canceled)
	action_events_container.add_child(new_action_remap_button)
	new_action_remap_button.grab_focus()
	new_action_remap_button.pressed.emit()

func _on_remove_button_pressed (row):
	remove_row(row)


func _on_empty_remap_canceled (button_source):
	remove_row(button_source.get_parent())

func remove_row (row):
	action_events_container.remove_child(row)
	row.queue_free()
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


func _on_is_toggle_check_toggled(toggled_on):
	InputEnhancer.set_togglable(action, toggled_on)

extends Button
class_name ActionRemapButton

signal empty_remap_canceled(button_source)

enum RemapEventType {
	ANY,
	KEYBOARD,
	MOUSE,
	JOY
}

@export var action : String
@export var remap_event_type: RemapEventType
@export var action_event : InputEvent

var consume_input : bool

func setup(action_to_remap : String, remap_type: RemapEventType, current_event : InputEvent):
	action = action_to_remap
	action_event = current_event
	remap_event_type = remap_type

	var event_index := InputMap.action_get_events(action).find(current_event)
	icon = InputIcon.get_icon(action, event_index)

func _input(event):
	if not consume_input:
		return

	if event is InputEventJoypadMotion and absf(event.axis_value) < InputMap.action_get_deadzone(action):
		return
		
	if event is InputEventMouseMotion:
		return

	get_viewport().set_input_as_handled()

	if event.is_action_pressed("ui_cancel") or event.is_action(action):
		if action_event != null:
			text = " "
			icon = InputIcon.get_icon_by_event(action_event)
			consume_input = false
		else:
			empty_remap_canceled.emit(self)
		return

	if remap_event_type != RemapEventType.ANY:
		if event is InputEventKey and remap_event_type != RemapEventType.KEYBOARD:
			return
			
		if event is InputEventMouse and remap_event_type != RemapEventType.MOUSE:
			return
			
		if (event is InputEventJoypadButton or event is InputEventJoypadMotion) and remap_event_type != RemapEventType.JOY:
			return
	
	consume_input = false
	var event_index = InputMap.action_get_events(action).find(event)
	if event_index >= 0:
		InputMap.action_erase_event(action, action_event)

	action_event = event
	InputMap.action_add_event(action, action_event)

	text = " "
	icon = InputIcon.get_icon_by_event(action_event)

func _on_pressed():
	icon = null
	text = "..."
	consume_input = true

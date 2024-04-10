extends Button
class_name ActionRemapButton

signal empty_remap_canceled(button_source)
signal remap_completed(button_source, old_event, new_event)

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

	if action_event:
		icon = InputIcon.get_icon_by_event(action_event)

func _input(event):
	if not consume_input:
		return

	if InputEnhancer.is_joy_motion_in_deadzone(action, event):
		return

	if event is InputEventMouseMotion:
		return

	get_viewport().set_input_as_handled()

	if event.is_action_pressed("ui_cancel") or event.is_action(action, true):
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

	InputEnhancer.replace_event(action, action_event, event)
	remap_completed.emit(self, action_event, event)
	action_event = event

	text = " "
	icon = InputIcon.get_icon_by_event(action_event)

func _on_pressed():
	icon = null
	text = "..."
	consume_input = true

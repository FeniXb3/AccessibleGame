extends Button
class_name ActionRemapButton

enum RemapEventType {
	ANY,
	KEYBOARD,
	MOUSE,
	JOY
}

@export var action : String
@export var remap_event_type: RemapEventType
@export var events : Array[InputEvent]
@export var index_of_type := 0

var consume_input : bool
var event_index : int

func setup(action_to_remap : String, current_events : Array[InputEvent], remap_type: RemapEventType, index: int = 0):
	action = action_to_remap
	events = current_events
	remap_event_type = remap_type
	index_of_type = index
	var filtered = events.filter(_filter_events_by_type)
	if filtered.size() > index_of_type:
		event_index = events.find(filtered[index_of_type])
		icon = InputIcon.get_icon(action, event_index)
	else:
		event_index = -1

func _filter_events_by_type(e: InputEvent):
	var x := typeof(e)
	print("Typeof: %s" % x)
	match remap_event_type:
		RemapEventType.KEYBOARD:
			return e is InputEventKey
		RemapEventType.MOUSE:
			return e is InputEventMouse
		RemapEventType.JOY:
			return e is InputEventJoypadButton or e is InputEventJoypadMotion

func _input(event):
	if not consume_input:
		return

	if event is InputEventJoypadMotion and absf(event.axis_value) < InputMap.action_get_deadzone(action):
		return
		
	if event is InputEventMouseMotion:
		return

	get_viewport().set_input_as_handled()

	if event.is_action_pressed("ui_cancel"):
		text = " "
		icon = InputIcon.get_icon(action, event_index)
		consume_input = false	
		return
	
	if event is InputEventKey and remap_event_type != RemapEventType.KEYBOARD:
		return
		
	if event is InputEventMouse and remap_event_type != RemapEventType.MOUSE:
		return
		
	if (event is InputEventJoypadButton or event is InputEventJoypadMotion) and remap_event_type != RemapEventType.JOY:
		return
	
	consume_input = false
	
	if event_index < 0:
		event_index = events.size()
		events.append(event)
		InputMap.action_add_event(action, event)
	else:
		events[event_index] = event
		InputMap.action_erase_events(action)
		for e in events:
			InputMap.action_add_event(action, e)
		
	text = " "
	icon = InputIcon.get_icon(action, event_index)
	
	#icon = InputIcon.get_icon_by_event(event)

func _on_pressed():
	icon = null
	text = "..."
	consume_input = true

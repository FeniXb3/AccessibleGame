extends HBoxContainer
class_name ControlOption

@export var action : String
@export var events : Array[InputEvent]
@export var variable : ColorVariable

@onready var label = %Label
@onready var button = %Button

var consume_input : bool

func _ready():
	label.text = action
	button.text = " "
	button.icon = InputIcon.get_icon(action)

func _on_button_pressed():
	button.icon = null
	button.text = "..."
	consume_input = true
	
func _input(event):
	if not consume_input:
		return

	if event is InputEventJoypadMotion and absf(event.axis_value) < InputMap.action_get_deadzone(action):
		return
		
	if event is InputEventMouseMotion:
		return

	get_viewport().set_input_as_handled()
	consume_input = false

	if event.is_action_pressed("ui_cancel"):
		button.text = " "
		button.icon = InputIcon.get_icon(action)
		return
	
	# TODO fix erasing single event
	#InputMap.action_erase_event(action, events[0])
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	button.text = " "
	button.icon = InputIcon.get_icon_by_event(event)
	
func focus_button():
	button.grab_focus()

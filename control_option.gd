extends HBoxContainer
class_name ControlOption

@export var action : String
@export var events : Array[InputEvent]
@export var variable : ColorVariable

@onready var label = %Label
#@onready var button = %Button
@onready var keyboard_action_remap_button : ActionRemapButton = %KeyboardActionRemapButton
@onready var mouse_action_remap_button : ActionRemapButton = %MouseActionRemapButton
@onready var joy_action_remap_button : ActionRemapButton = %JoyActionRemapButton

var consume_input : bool

func _ready():
	label.text = action
	events = InputMap.action_get_events(action)
	
	keyboard_action_remap_button.setup(action, events)
	mouse_action_remap_button.setup(action, events)
	joy_action_remap_button.setup(action, events)

func focus_button():
	keyboard_action_remap_button.grab_focus()

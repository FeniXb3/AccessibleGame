extends HBoxContainer
class_name RemappingRow

signal remove_button_pressed(row)

@export var action : StringName
@export var action_remap_button_scene : PackedScene

@onready var action_remap_button : ActionRemapButton = %ActionRemapButton
#var action_remap_button : ActionRemapButton
@onready var remove_action_event = %RemoveActionEvent
@export var remap_event_type: ActionRemapButton.RemapEventType
@export var action_event : InputEvent

func setup(action_to_remap : String, remap_type: ActionRemapButton.RemapEventType, current_event : InputEvent):
	action = action_to_remap
	remap_event_type = remap_type
	action_event = current_event
	#action_remap_button = action_remap_button_scene.instantiate()
	#action_remap_button.setup(action_to_remap, remap_type, current_event)
	#add_child(action_remap_button)

	#var remove_button := Button.new()
	#remove_button.text = "Remove"
	#remove_button.pressed.connect(_on_remove_action_event_pressed)
	#add_child(remove_button)

func _ready():
	action_remap_button.setup(action, remap_event_type, action_event)


func _on_remove_action_event_pressed():
	InputEnhancer.action_erase_event(action, action_remap_button.action_event)
	remove_button_pressed.emit(self)

func invoke_remapping():
	action_remap_button.grab_focus()
	action_remap_button.pressed.emit()

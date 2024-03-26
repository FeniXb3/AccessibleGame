extends CanvasLayer
@onready var animation_player = %AnimationPlayer
@onready var subtitle : RichTextLabel = %Subtitle
@onready var external_margin_container = %ExternalMarginContainer
@export var theme : Theme
@export var speech_player : AudioStreamPlayer

func _ready():
	external_margin_container.theme = theme
	
	var data = {
		"TextPath": "res://star_wars_example.txt", 
		"Label": subtitle,
		"AnimationPlayer": animation_player, 
		"Name": "display_subtitles", 
		"Style": "subtitles",
		"Container": external_margin_container,
	}
	Captions.generate_animation(data)
	animation_player.play("display_subtitles")
	if speech_player:
		speech_player.play()

func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		var current_font_size := theme.default_font_size
		print(current_font_size)
		theme.default_font_size += 10
	elif Input.is_action_just_pressed("ui_down"):
		var current_font_size := theme.default_font_size
		print(current_font_size)
		theme.default_font_size -= 10

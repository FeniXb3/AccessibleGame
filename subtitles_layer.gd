extends CanvasLayer
@onready var animation_player = %AnimationPlayer
@onready var subtitle : RichTextLabel = %Subtitle
@onready var external_margin_container = %ExternalMarginContainer
@export var speech_player : AudioStreamPlayer

func _ready():
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

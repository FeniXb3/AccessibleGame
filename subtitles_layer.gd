extends CanvasLayer
@onready var animation_player = %AnimationPlayer
@onready var subtitle : RichTextLabel = %Subtitle
@onready var external_margin_container = %ExternalMarginContainer

func _ready():
	var data = {
		"TextPath": "res://star_wars_example.txt", 
		"Label": subtitle,
		"AnimationPlayer": animation_player, 
		"Name": "display_subtitles", 
		"Style": "subtitles",
		"Container": external_margin_container,
		# "Duration": 15
	} # Settings which will be passed as an argument.
	Captions.create(data)
	animation_player.play("display_subtitles")

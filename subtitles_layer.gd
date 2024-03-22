extends CanvasLayer
@onready var animation_player = %AnimationPlayer
@onready var tmp = $CanvasLayer/Panel/Tmp
@onready var subtitle = %Subtitle

func _ready():
	var data = {"TextPath": "res://text_file_format_example.txt", "Label": subtitle, "AnimationPlayer": animation_player, "Name": "display_subtitles", "Style": "word"} # Settings which will be passed as an argument.
	Captions.create(data)
	animation_player.play("display_subtitles")

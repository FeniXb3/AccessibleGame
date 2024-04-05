extends MarginContainer
@onready var animation_player = %AnimationPlayer
@onready var subtitle : RichTextLabel = %Subtitle
#@onready var external_margin_container = %ExternalMarginContainer
@export var subtitles_theme : Theme
@export var speech_player : AudioStreamPlayer
@export var animate_when_paused := false
@onready var panel_container = %PanelContainer

var library_name := "local"


func _ready():
	Captions.subtitle_creation_requested.connect(_on_subtitle_creation_requested)
	Captions.subtitle_play_requested.connect(_on_subtitle_play_requested)
	
	#external_margin_container.theme = subtitles_theme
	theme = subtitles_theme
	
func _play_example():
	var data = {
		"TextPath": "res://star_wars_example.txt", 
		"Label": subtitle,
		"AnimationPlayer": animation_player, 
		"Name": "display_subtitles",
		"LibraryName": library_name,
		"Style": "subtitles",
		"Container": panel_container #external_margin_container,
	}
	Captions.generate_animation(data)
	animation_player.play("display_subtitles")
	if speech_player:
		speech_player.play()

# TODO
# create signal for playing subtitles animation with specific name (maybe taken from the name of audio file?
# create subtitles menu draft - changing font with size, outline and shadow, changing panel color and corners, changing margins 

func _on_subtitle_creation_requested(text_path: String, animation_name : String):
	assert(text_path, "SRT text or file path is required to create subtitles")
	assert(animation_name, "Subtitle animation name is required to distinguish different subtitles")
	assert(not animation_player.has_animation(animation_name), "Animation with this name already exists")
	
	var data = {
		"TextPath": text_path, 
		"Name": animation_name, 
		"LibraryName": library_name,
		"Label": subtitle,
		"AnimationPlayer": animation_player, 
		"Style": "subtitles",
		"Container": panel_container #external_margin_container,
	}
	Captions.generate_animation(data)

func _on_subtitle_play_requested(animation_name: String):
	if not (animate_when_paused and get_tree().paused):
		return

	assert(animation_name, "Subtitle animation name is required to play it")
	print(animation_player.get_animation_list())
	animation_player.play("%s/%s" % [library_name, animation_name])

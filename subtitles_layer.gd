extends CanvasLayer
@onready var animation_player = %AnimationPlayer
@onready var subtitle : RichTextLabel = %Subtitle
@onready var external_margin_container = %ExternalMarginContainer
@export var theme : Theme
@export var speech_player : AudioStreamPlayer


func _ready():
	Captions.subtitle_creation_requested.connect(_on_subtitle_creation_requested)
	Captions.subtitle_play_requested.connect(_on_subtitle_play_requested)
	
	external_margin_container.theme = theme
	
func _play_example():
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
		"Label": subtitle,
		"AnimationPlayer": animation_player, 
		"Style": "subtitles",
		"Container": external_margin_container,
	}
	Captions.generate_animation(data)

func _on_subtitle_play_requested(animation_name: String):
	assert(animation_name, "Subtitle animation name is required to play it")
	
	animation_player.play(animation_name)
#
#func _process(_delta):
	#if Input.is_action_just_pressed("ui_up"):
		#var current_font_size := theme.default_font_size
		#print(current_font_size)
		#theme.default_font_size += 10
	#elif Input.is_action_just_pressed("ui_down"):
		#var current_font_size := theme.default_font_size
		#print(current_font_size)
		#theme.default_font_size -= 10
	#elif Input.is_action_just_pressed("ui_accept"):
		#theme.set_constant("margin_bottom", "MarginContainer", 300)
		
		
	

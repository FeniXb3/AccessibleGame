extends Control

@onready var text_path = %TextPath
@onready var animation_name = %AnimationName
@onready var create = %Create
@onready var play = %Play


func _on_create_pressed():
	Captions.subtitle_creation_requested.emit(text_path.text, animation_name.text)


func _on_play_pressed():
	Captions.subtitle_play_requested.emit(animation_name.text)


func _on_prepare_example_pressed():
	text_path.text = "res://addons/subtitles/star_wars_example.txt"
	animation_name.text = "example"

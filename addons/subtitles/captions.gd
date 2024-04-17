extends Node
# Based on Godot Speech To Subtitles by 10thello
# MIT license
# https://github.com/FeniXb3/godot-speech-to-subtitles


signal subtitle_creation_requested(text_path: String, animation_name : String)
signal subtitle_play_requested(animation_name: String)

func generate_animation(data: Dictionary) -> Animation:
	assert(data.get("TextPath"), "TextPath is required")
	assert(data.get("Label"), "Label is required")
	var caption_fields := read_and_parse(data["TextPath"])

	match data.get("Style", "letters").to_lower():
		"word":
			return _generate_animation_WORDS(data, caption_fields)
		"subtitles":
			return _generate_animation_subtitles(data, caption_fields)
		_:
			return _generate_animation_LETTERS(data, caption_fields)

func read_and_parse(text_path : String) -> Array:
	var caption_fields := []

	if text_path.is_absolute_path():
		var raw_file := FileAccess.open(text_path, FileAccess.READ)
		caption_fields = _parse_subtitles(raw_file.get_as_text())
		raw_file.close()
	else:
		caption_fields = _parse_subtitles(text_path)

	return caption_fields

func get_complete_template() -> Dictionary:
	var template = {"TextPath": "PATH TO .TXT FILE (REQUIRED)", # Required
	"Label": "LABEL OR RICHTEXTLABEL NODE (REQUIRED)", # Required
	"Name": "NEW ANIMATION NAME (OPTIONAL)", # Optional
	"AnimationPlayer": "ANIMATIONPLAYER NODE (OPTIONAL)", # Optional
	"Duration": "AUDIO LENGTH (OPTIONAL)", # Optional
	"Style": "WORD OR LETTER (OPTIONAL)", # Optional
	"Container": "NODE CONTAINING THE LABEL TO BE ENABLED/DISABLED ON START/END OF EACH SEGMENT (OPTIONAL)" # Optional
	}
	return template

func get_required_template() -> Dictionary:
	var template = {"TextPath": "PATH TO .TXT FILE (REQUIRED)", "LABEL": "LABEL OR RICHTEXTLABEL NODE (REQUIRED)"}
	return template

func _parse_subtitles(content : String) -> Array:
	var caption_fields := []
	var content_regex := RegEx.new()
	content_regex.compile(r'\d+[\r\n]((?<start>\d+:\d+:\d+,\d+) --> (?<end>\d+:\d+:\d+,\d+))[\r\n](?<text>(.+\r?\n)+(?=(\r?\n)?))')
	for result in content_regex.search_all(content):
		caption_fields.append({
			"text": result.get_string("text").strip_edges(),
			"start": _timestamp_to_seconds(result.get_string("start")),
			"end": _timestamp_to_seconds(result.get_string("end"))
		})
	return caption_fields

func _timestamp_to_seconds(timestamp : String) -> float:
	var segments = timestamp.split(":")
	return float(segments[0]) * 3600 + float(segments[1]) * 60 + float(segments[2].split(",")[0]) + float(segments[2].split(",")[1]) / 1000.0

func _generate_animation_WORDS(data : Dictionary, caption_fields : Array[Dictionary]) -> Animation:
	var animation := Animation.new()
	var track_index := _prepare_track(animation, data["Label"], Animation.UPDATE_DISCRETE)
	var last_field : Dictionary = caption_fields.pop_back()
	var written := ""
	for caption in caption_fields:
		written = _add_segment_word_by_word_to_track(written, caption, animation, track_index)

	var duration : float = data.get("Duration", last_field["end"])
	written = _add_segment_word_by_word_to_track(written, last_field, animation, track_index, duration)

	animation.length = duration

	if "AnimationPlayer" in data and "Name" in data:
		data["AnimationPlayer"].get_animation_library(data["LibraryName"]).add_animation(data["Name"], animation)

	return animation

func _generate_animation_LETTERS(data : Dictionary, caption_fields) -> Animation:
	var animation := Animation.new()
	var track_index := _prepare_track(animation, data["Label"], Animation.UPDATE_CONTINUOUS)
	var full_script := ""
	var last_key_index : int = -1
	for caption in caption_fields:
		var text : String = caption["text"]
		var start : float = caption["start"]
		var end : float = caption["end"]

		animation.track_insert_key(track_index, start, full_script)
		full_script += text + " "
		last_key_index = animation.track_insert_key(track_index, end, full_script)

	var duration : float = data.get("Duration", caption_fields.back()["end"])
	animation.track_set_key_time(track_index, last_key_index, duration)

	animation.length = duration

	if "AnimationPlayer" in data and "Name" in data:
		data["AnimationPlayer"].get_animation_library(data["LibraryName"]).add_animation(data["Name"], animation)

	return animation

func _generate_animation_subtitles(data : Dictionary, caption_fields) -> Animation:
	var animation := Animation.new()
	var track_index := _prepare_track(animation, data["Label"], Animation.UPDATE_DISCRETE)
	var has_container := data.has("Container")
	var container_track_index := -1 if not has_container else _prepare_track(animation, data["Container"], Animation.UPDATE_DISCRETE, "visible")

	for caption in caption_fields:
		var text : String = caption["text"]
		var start : float = caption["start"]
		var end : float = caption["end"]

		animation.track_insert_key(track_index, start, text)
		animation.track_insert_key(track_index, end, "")

		if has_container:
			animation.track_insert_key(container_track_index, start, true)
			animation.track_insert_key(container_track_index, end, false)

	var duration : float = data.get("Duration", caption_fields.back()["end"])
	animation.length = duration

	if "AnimationPlayer" in data and "Name" in data: # Adds the named animation to the provded animation player.
		data["AnimationPlayer"].get_animation_library(data["LibraryName"]).add_animation(data["Name"], animation)

	return animation

func _prepare_track(animation : Animation, node, update_mode : Animation.UpdateMode, property = "text") -> int:
	var track_index := animation.add_track(Animation.TYPE_VALUE)
	var nodePath := NodePath(node.owner.get_path_to(node))

	animation.value_track_set_update_mode(track_index, update_mode)
	animation.track_set_path(track_index, "%s:%s" % [nodePath.get_concatenated_names(), property])

	return track_index

func _add_segment_word_by_word_to_track(written : String, caption, animation : Animation, track_index : int, end_override := 0.0) -> String:
	var text : String = caption["text"]
	var start : float = caption["start"]
	var end : float = caption["end"] if not end_override else end_override
	var words := text.split(" ")
	var segment_duration := end - start
	var word_duration := segment_duration / words.size()

	var currentTime := start
	for word in words:
		currentTime += word_duration
		written += word + " "
		animation.track_insert_key(track_index, currentTime, written)

	return written

extends Node

func prepare_track(animation : Animation, node, update_mode : Animation.UpdateMode, property = "text") -> int:
	var track_index := animation.add_track(Animation.TYPE_VALUE)
	var owner = node.owner
	var nodePath = NodePath(node.owner.get_path_to(node))
	animation.value_track_set_update_mode(track_index, update_mode)
	animation.track_set_path(track_index, "%s:%s" % [nodePath.get_concatenated_names(), property])
	
	return track_index

func add_segment_word_by_word_to_track(written : String, caption, animation : Animation, track_index : int, end_override := 0.0) -> String:
	var text := caption["text"] as String # The text being displayed.
	var start := caption["start"] as float # The starting keyframe in seconds.
	var end := caption["end"] as float if not end_override else end_override # The ending keyframe in seconds.
	var words := text.split(" ") # Get every word.
	var segment_duration := end - start
	var word_duration = segment_duration / words.size()

	var currentTime = start
	for word in words:
		currentTime += word_duration
		written += word + " "
		animation.track_insert_key(track_index, currentTime, written)
		
	return written

func generate_animation_WORDS(data : Dictionary, caption_fields):
	var animation := Animation.new()
	var track_index := prepare_track(animation, data["Label"], Animation.UPDATE_DISCRETE)
	var last_field = caption_fields.pop_back()
	var written := ""
	for caption in caption_fields:
		written = add_segment_word_by_word_to_track(written, caption, animation, track_index)
	
	var duration : float = data.get("Duration", last_field["end"]) 
	written = add_segment_word_by_word_to_track(written, last_field, animation, track_index, duration)
	
	animation.length = duration
	
	if "AnimationPlayer" in data and "Name" in data: # Adds the named animation to the provded animation player.
		data["AnimationPlayer"].get_animation_library("").add_animation(data["Name"], animation)
		return true
	else: # Returns the animation.
		return animation

func generate_animation_LETTERS(data, caption_fields):
	var animation := Animation.new()
	var track_index = prepare_track(animation, data["Label"], Animation.UPDATE_CONTINUOUS)
	var last_field = caption_fields.pop_back()
	var full_script = ""
	var text := ""
	for caption in caption_fields:
		text = caption["text"] # The text being displayed.
		var start = caption["start"] # The starting keyframe in seconds.
		var end = caption["end"] # The ending keyframe in seconds.
		animation.track_insert_key(track_index, start, full_script)
		full_script += text + " "
		animation.track_insert_key(track_index, end, full_script)
	
	text = last_field["text"]

	animation.track_insert_key(track_index, last_field["start"], full_script)
	full_script += last_field["text"]
		
	var duration : float = data.get("Duration", last_field["end"]) 
	
	animation.track_insert_key(track_index, duration, full_script)
	
	animation.length = duration
	
	if "AnimationPlayer" in data and "Name" in data: # Adds the named animation to the provded animation player.
		data["AnimationPlayer"].get_animation_library("").add_animation(data["Name"], animation)
		return true
	else: # Returns the animation.
		return animation
	
func generate_animation_subtitles(data, caption_fields):
	var animation := Animation.new()
	var track_index = prepare_track(animation, data["Label"], Animation.UPDATE_DISCRETE)
	var container_track_index = prepare_track(animation, data["Container"], Animation.UPDATE_DISCRETE, "visible")
	print((data["AnimationPlayer"] as AnimationPlayer).root_node)
	for caption in caption_fields:
		var text = caption["text"]
		var start = caption["start"]
		var end = caption["end"]
		animation.track_insert_key(container_track_index, start, true)
		animation.track_insert_key(track_index, start, text)
		animation.track_insert_key(track_index, end, "")
		animation.track_insert_key(container_track_index, end, false)
	
	var duration : float = caption_fields.back()["end"]# - caption_fields.front()["start"]
	animation.length = duration
	
	if "AnimationPlayer" in data and "Name" in data: # Adds the named animation to the provded animation player.
		data["AnimationPlayer"].get_animation_library("").add_animation(data["Name"], animation)
	
	return animation

func parse_subtitles(content : String) -> Array:
	var caption_fields := []	
	var content_regex := RegEx.new()
	content_regex.compile(r'\d+[\r\n]((?<start>\d+:\d+:\d+,\d+) --> (?<end>\d+:\d+:\d+,\d+))[\r\n](?<text>(.+\r?\n)+(?=(\r?\n)?))')
	for result in content_regex.search_all(content):
		caption_fields.append({
			"text": result.get_string("text").strip_edges(), 
			"start": timestamp_to_seconds(result.get_string("start")), 
			"end": timestamp_to_seconds(result.get_string("end"))
		})
	return caption_fields

func create(data: Dictionary): # Creates and returns a label animation with the captions provided.
	var caption_fields := []
	
	var text_path : String = data["TextPath"]
	if text_path.is_absolute_path():
		var raw_file := FileAccess.open(text_path, FileAccess.READ)
		var content := raw_file.get_as_text()
		caption_fields = parse_subtitles(content)
		raw_file.close()
	else:
		caption_fields = parse_subtitles(text_path)
		
	if "TimeOnly" in data and data["TimeOnly"]: # Returns caption fields without animating them.
		return caption_fields
	
	if "Style" in data: # The style of the animation.
		if data["Style"].to_lower() == "word":
			var outcome = generate_animation_WORDS(data, caption_fields)
			return outcome
		elif  data["Style"].to_lower() == "subtitles":
			return generate_animation_subtitles(data, caption_fields)
		else:
			var outcome = generate_animation_LETTERS(data, caption_fields)
			return outcome
	else: # Uses LETTERS as default.
		var outcome = generate_animation_LETTERS(data, caption_fields)
		return outcome

func timestamp_to_seconds(timestamp : String) -> float:
	var segments = timestamp.split(":")
	return float(segments[0]) * 3600 + float(segments[1]) * 60 + float(segments[2].split(",")[0]) + float(segments[2].split(",")[1]) / 1000.0

func get_complete_template():
	var template = {"TextPath": "PATH TO .TXT FILE (REQUIRED)", # Required
	"Label": "LABEL OR RICHTEXTLABEL NODE (REQUIRED)", # Required
	"Name": "NEW ANIMATION NAME (OPTIONAL)", # Optional
	"AnimationPlayer": "ANIMATIONPLAYER NODE (OPTIONAL)", # Optional
	"Duration": "AUDIO LENGTH (OPTIONAL)", # Optional
	"Style": "WORD OR LETTER (OPTIONAL)", # Optional
	"TimeOnly": "TRUE OR FALSE (OPTIONAL)" # Optional
	}
	return template
	
func get_required_template():
	var template = {"TextPath": "PATH TO .TXT FILE (REQUIRED)", "LABEL": "LABEL OR RICHTEXTLABEL NODE (REQUIRED)"}
	return template

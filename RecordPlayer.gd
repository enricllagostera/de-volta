extends Node2D

export(NodePath) var source_node
export var history = []
export var initial_ticks = 0
onready var source = get_node(source_node)
var history_index = 0
var timer = 0.0
var playback_time_scale


func _ready():
	history_index = 0
	load_history()
	timer = 0.0


func _process(delta):
	timer += delta
	var next_index = get_next_index(history_index)
	var next_tick_time = history[next_index].tick - initial_ticks
	while timer >= next_tick_time:
		history_index = get_next_index(history_index)
		if history_index == 0:
			timer = 0.0
		next_index = get_next_index(history_index)
		next_tick_time = history[next_index].tick - initial_ticks
	var next_position = str2var("Vector2" + history[history_index].position)
	rotation_degrees = history[history_index].rotation_degrees
	position = next_position


func get_next_index(from_index):
	return 0 if (from_index + 1) >= history.size() else from_index + 1


func load_history():
	var path = "user://record_" + source.name + ".sav"
	# Check if there is a saved file
	var file = File.new()
	if not file.file_exists(path):
		print("No file saved!")
		return
	# Try to open existing file
	if file.open(path, File.READ) != 0:
		print("Error opening file")
		return
	# All is OK, get the data
	var data = parse_json(file.get_line())
	history = data.history
	initial_ticks = data.initial_ticks

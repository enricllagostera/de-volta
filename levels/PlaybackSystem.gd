extends Node2D

export(Array) var launch_points = []
export(NodePath) var player_node
export(PackedScene) var ghost_prefab

onready var launchpad_count = launch_points.size()
onready var player = get_node(player_node)
onready var play_count = Main.play_count;

var current_launchpad_index
var level_name = "level_one"


func prepare_player_and_ships(map_index):
	level_name = Main.get_current_level_name()
#	Calculate current launch point current_launchpad_index based on number of plays
	var local_count = Main.levels[map_index].level_plays
	current_launchpad_index = local_count % launchpad_count
#	Instantiate recorded ghost ships on remaining launch points
	for ghost_index in launchpad_count:
#		Only load history if there is a playthrough for this launchpad
#		AND it isn't the current launchpad
		if play_count >= ghost_index and ghost_index != current_launchpad_index:
			add_ghost(ghost_index)
#	Move Starship to its starting location
	var current_launchpad = get_node(launch_points[current_launchpad_index]).position;
	player.position = current_launchpad
	$Recorder.launchpad_index = current_launchpad



func add_ghost(index):
	var history = load_history(index)
	if history == null or history.size() == 0:
		return
	var new_ghost = ghost_prefab.instance()
	new_ghost.launchpad_index = index
	new_ghost.history = load_history(index)
	add_child(new_ghost)
	new_ghost.position = get_node(launch_points[index]).position
	new_ghost.start()
	


func save_level_history(history, launchpad_index):
	Main.save_history(history, player.name, level_name, launchpad_index)


func load_history(launchpad_index):
	var path = "user://record-"+ player.name + "-" + level_name + "-" + str(launchpad_index) +".sav";
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
	var history = data.history
	return history


func _on_Starship_goal_reached(_launch_count, _energy):
	$Recorder.prepare_for_saving()
	save_level_history($Recorder.history, current_launchpad_index)

extends Node

export var play_count = 0
var current_level = 0

var levels = [
	{"name": "Level1", "level_plays": 0, "launchpad_count": 5},
	{"name": "Level2", "level_plays": 0, "launchpad_count": 5},
	{"name": "Level3", "level_plays": 0, "launchpad_count": 5}
]


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		erase_saved_histories();
		get_tree().quit() # default behavior


func erase_saved_histories():
	for level in levels:
		for ghost_index in level.launchpad_count:
			save_history([], "Starship", level.name, ghost_index)


func advance_level():
	levels[current_level].level_plays += 1
	play_count += 1
	current_level = play_count % 3


func change_level(level_name):
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	current_scene.queue_free()
	var new_level = load("res://levels/"+ level_name +".tscn").instance()
	get_tree().get_root().add_child(new_level)


func get_current_level_plays():
	return levels[current_level].level_plays;


func get_current_level_name():
	return levels[current_level].name;


func reload_current_level():
	change_level(levels[current_level].name)


func save_history(history, object_name, level_name, launchpad_index):
	var file = File.new();
	var path = "user://record-"+ object_name + "-" + level_name + "-" + str(launchpad_index) +".sav";
#	print(path);
	if file.open(path, File.WRITE) != 0:
		print("Error opening file")
		return
	var data = {}
	data.history = history
	file.store_line(to_json(data))
	file.close()

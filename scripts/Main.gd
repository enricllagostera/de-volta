extends Node

export var play_count = 0
var current_level = 0

var levels = [
	{"name": "Level1", "level_count": 0},
	{"name": "Level2", "level_count": 0},
	{"name": "Level3", "level_count": 0}
]


func advance_level():
	levels[current_level].level_count += 1
	play_count += 1
	current_level = play_count % 3


func change_level(level_name):
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	current_scene.queue_free()
	var new_level = load("res://levels/"+ level_name +".tscn").instance()
	get_tree().get_root().add_child(new_level)


func get_current_level_name():
	return levels[current_level].name;


func reload_current_level():
	change_level(levels[current_level].name)

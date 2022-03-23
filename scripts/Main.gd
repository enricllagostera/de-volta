extends Node

export var play_count = 0
export var current_health = 100
export var current_energy = 100
var current_level = 0
var current_level_name := "TitleScreen"
export var lives = 3

var levels = [
	{"name": "Level1", "level_plays": 0, "launchpad_count": 5},
]


func _ready():
	$PermanentGUI/FullscreenBtn.connect("pressed", self, "on_fullscreen")
	$PermanentGUI/QuitBtn.connect("pressed", self, "on_quit")


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		erase_saved_histories()
		get_tree().quit()  # default behavior


func erase_saved_histories():
	for level in levels:
		for ghost_index in level.launchpad_count:
			save_history([], "Starship", level.name, ghost_index)


func advance_level(health, energy):
	lives = 3
	current_health = health
	current_energy = energy
	levels[current_level].level_plays += 1
	play_count += 1
	#current_level = play_count % 3


func change_level(level_name):
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	current_scene.queue_free()
	var new_level = load("res://levels/" + level_name + ".tscn").instance()
	current_level_name = level_name
	get_tree().get_root().add_child(new_level)


func get_current_level_plays():
	return levels[current_level].level_plays


func get_current_level_name():
	return levels[current_level].name


func reload_current_level():
	change_level(levels[current_level].name)


func lose_life():
	lives -= 1
	if lives <= 0:
		print("game over!")
		erase_saved_histories()
		change_level("GameOverLevel")


func reset_game():
	lives = 3
	play_count = 0
	current_health = 100
	current_energy = 100
	current_level = 0
	levels[current_level].level_plays = 0


func save_history(history, object_name, level_name, launchpad_index):
	var file = File.new()
	var path = (
		"user://record-"
		+ object_name
		+ "-"
		+ level_name
		+ "-"
		+ str(launchpad_index)
		+ ".sav"
	)
#	print(path);
	if file.open(path, File.WRITE) != 0:
		print("Error opening file")
		return
	var data = {}
	data.history = history
	file.store_line(to_json(data))
	file.close()


func on_fullscreen():
	OS.window_fullscreen = !OS.window_fullscreen


func on_quit():
	if OS.window_fullscreen and current_level_name == "TitleScreen":
		OS.window_fullscreen = false
	reset_game()
	erase_saved_histories()
	change_level("TitleScreen")

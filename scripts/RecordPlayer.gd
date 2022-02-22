extends Node2D

export(NodePath) var source_node
export var history = []
export var initial_ticks = 0
onready var source = get_node(source_node)

var launchpad_index = 0
var history_index = 0
var timer = 0.0
var playback_time_scale
var level_name


func _ready():
	history_index = 0
	timer = 0.0
	stop()


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


func start():
	initial_ticks = history[0].tick
	play()


func play():
	set_process(true)


func stop():
	set_process(false)


func _on_GhostShip_body_entered(body):
	if body is Starship:
		print("hit player")
		body.touched_ghost(self)
	pass # Replace with function body.

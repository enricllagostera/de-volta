extends Node2D

onready var initial_ticks = 0.0;
export onready var history = []
export(NodePath) var position_target;
export(NodePath) var rotation_target;

onready var pos_target = get_node(position_target)
onready var rot_target = get_node(rotation_target)

export var save_on_exit = true;

var movement_threshold = 1.0;
var old_position = Vector2.ZERO;
var timeSinceReady = 0.0;

func _ready():
	save_on_exit = false;

func _process(delta):
	timeSinceReady += delta;
	var new_record = {};
	var pos = pos_target.position
	if pos.distance_to(old_position) >= movement_threshold:
		new_record.position = pos
		old_position = pos
		new_record.rotation_degrees = rot_target.rotation_degrees;
		new_record.time_scale = Engine.time_scale
	if not new_record.empty():
		new_record.tick = timeSinceReady; 
		add_record(new_record);

func add_record(record):
	history.append(record);
	
func _exit_tree():
	# Create a last record to show stopped
	var new_record = {};
	new_record.position = pos_target.position
	new_record.rotation_degrees = rot_target.rotation_degrees;
	new_record.time_scale = Engine.time_scale
	new_record.tick = timeSinceReady; 
	add_record(new_record);
	if save_on_exit:
		save_history();
	
func save_history():
	var file = File.new();
	var path = "user://record_"+ pos_target.name + ".sav";
	if file.open(path, File.WRITE) != 0:
		print("Error opening file")
		return
	var data = {}
	data.initial_ticks = initial_ticks
	data.history = history
	print(path);
	file.store_line(to_json(data))
	file.close()


func _on_Starship_goal_reached(_launch_count, _energy):
	save_on_exit = true;

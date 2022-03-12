extends Node2D

export var save_on_exit = true
export(NodePath) var position_target
export(NodePath) var rotation_target

export onready var history = []
export onready var level_name = ""
export onready var launchpad_index = 0

onready var initial_ticks = 0.0
onready var pos_target = get_node(position_target)
onready var rot_target = get_node(rotation_target)

var movement_threshold = 0.5
var rotation_threshold = 1
var old_position = Vector2.ZERO
var old_rotation = 0
var timeSinceReady = 0.0


func _ready():
	level_name = Main.get_current_level_name()
	save_on_exit = false


func _process(delta):
	timeSinceReady += delta
	var new_record = {}
	var pos = pos_target.position
	var rot = rot_target.rotation_degrees
	if (pos.distance_to(old_position) >= movement_threshold) or (abs(rot - old_rotation) >= rotation_threshold):
		old_position = pos
		old_rotation = rot
		new_record.position = pos
		new_record.rotation_degrees = rot_target.rotation_degrees
		new_record.time_scale = Engine.time_scale
	if not new_record.empty():
		new_record.tick = timeSinceReady
		add_record(new_record)


func add_record(record):
	history.append(record)


func prepare_for_saving():
	# Create a last record to show stopped
	var new_record = {}
	new_record.position = pos_target.position
	new_record.rotation_degrees = rot_target.rotation_degrees
	new_record.time_scale = Engine.time_scale
	new_record.tick = timeSinceReady
	add_record(new_record)

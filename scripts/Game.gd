extends Node2D
class_name Game

export(PackedScene) var level
export(PackedScene) var inbetween_scene
onready var inbetween


func _ready():
	var map = level.instance()
	map.name = "Map"
	add_child(map)
	$Map/Player/Starship.connect("goal_reached", self, "_on_Starship_goal_reached")
	$Map/Player/Starship.connect("died", self, "reset")

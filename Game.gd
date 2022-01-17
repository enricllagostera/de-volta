extends Node2D

export (PackedScene) var level;


func _ready():
	var map = level.instance();
	map.name = "Map";
	add_child(map);
	$Map/Player/Starship.connect("goal_reached", self, "_on_Starship_goal_reached");
	$Map/Player/Starship.connect("died", self, "reset");


func _on_Starship_goal_reached(_launch_count, _energy):
	$Map/Player/Starship.velocity = Vector2.ZERO
	$Map/Player/Starship.set_physics_process(false);
	$Map/Player/Starship.set_process(false);
	var tween = $Map/Player/Starship/Tween as Tween
	tween.interpolate_property($Map/Player/Starship/Visual,"scale", 
			Vector2(1.2, 1.2), Vector2.ZERO, 
			0.5, Tween.TRANS_ELASTIC, Tween.EASE_IN);
	tween.start();
	reset();


func reset():
	print("Reset timer started.");
	yield(get_tree().create_timer(1.0), "timeout");
	print("Timer ended.");
	assert(get_tree().reload_current_scene() == OK);

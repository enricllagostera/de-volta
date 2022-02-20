extends Area2D

export var rotation_speed = 3;


func _process(delta):
	$Visual.rotate(delta * rotation_speed);
	pass

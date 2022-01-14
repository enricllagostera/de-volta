extends Node2D


func _process(_delta):
	$DeathExplosion.position = $Starship.position;

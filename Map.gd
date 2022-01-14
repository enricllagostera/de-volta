extends Node2D


func _ready():
	get_tree().call_group("gravity_attractor", "add_body", $Player/Starship);


func _process(_delta):
	var target_pos = $Player/Starship.position
	$GameplayCamera2D.position = target_pos + Vector2(-400, -250);


func _on_Starship_navigation_engaged(is_active):
	$GameplayCamera2D.current = not is_active;
	$MapCamera2D.current = is_active;



extends Node2D

export var area_bounds: Rect2
export var map_camera_smooth: float = 2.0
var map_camera_target: Vector2


func _ready():
	get_tree().call_group("gravity_attractor", "add_body", $Player/Starship)


func _process(delta):
	if $MapCamera2D.current:
		$MapCamera2D.offset = lerp(
			$MapCamera2D.offset, map_camera_target, delta * map_camera_smooth
		)
	var target_pos = $Player/Starship.position
	$GameplayCamera2D.position = target_pos + Vector2(0, -25)
	if area_bounds.has_point(target_pos):
		$Player/Starship.entered_map_area()
	else:
		$Player/Starship.exited_map_area()


func _on_Starship_navigation_engaged(is_active):
	$GameplayCamera2D.current = not is_active
	$MapCamera2D.current = is_active


func _on_NavHSlider_value_changed(value):
	var new_x = range_lerp(
		value,
		0,
		100,
		$MapCamera2D.limit_left,
		$MapCamera2D.limit_right - OS.window_size.x * $MapCamera2D.zoom.x
	)
	map_camera_target.x = new_x


func _on_NavVSlider_value_changed(value):
	var new_y = range_lerp(
		100 - value,
		0,
		100,
		$MapCamera2D.limit_top,
		$MapCamera2D.limit_bottom - OS.window_size.y * $MapCamera2D.zoom.y
	)
	map_camera_target.y = new_y

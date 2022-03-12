extends Node2D

export var area_bounds: Rect2
export var map_camera_smooth: float = 2.0
var map_camera_target: Vector2
export var map_index = 0


func _ready():
	Main.current_level = map_index
	$PlaybackSystem.prepare_player_and_ships(map_index)
	get_tree().call_group("gravity_attractor", "add_body", $Player/Starship)
	$Player/Starship.connect("goal_reached", self, "_on_Starship_goal_reached")
	$Player/Starship.connect("died", self, "_on_Starship_died")
	$HUD/Lives/AnimationPlayer.play("lives"+str(Main.lives))
	$HUD/EnergyBarOverlay/AnimationPlayer.play("energy")
	$HUD/HealthBarOverlay/AnimationPlayer.play("health")


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


func reset():
	print("Reset timer started.")
	yield(get_tree().create_timer(2.0), "timeout")
	print("Timer ended.")
	Main.reload_current_level()


func _on_Starship_navigation_engaged(is_active):
	$GameplayCamera2D.current = not is_active
	$MapCamera2D.current = is_active


func _on_NavHSlider_value_changed(value):
	var new_x = range_lerp(
		value,
		0,
		100,
		$MapCamera2D.limit_left,
		$MapCamera2D.limit_right - 800 * $MapCamera2D.zoom.x
	)
	map_camera_target.x = new_x


func _on_NavVSlider_value_changed(value):
	var new_y = range_lerp(
		100 - value,
		0,
		100,
		$MapCamera2D.limit_top,
		$MapCamera2D.limit_bottom - 400 * $MapCamera2D.zoom.y
	)
	map_camera_target.y = new_y


func _on_Starship_goal_reached(_launch_count, _energy):
	$Player/Starship.velocity = Vector2.ZERO
	$Player/Starship.set_physics_process(false)
	$Player/Starship.set_process(false)
	var tween = $Player/Starship/Tween as Tween
	tween.interpolate_property(
		$Player/Starship/Visual,
		"scale",
		Vector2(1.2, 1.2),
		Vector2.ZERO,
		0.5,
		Tween.TRANS_ELASTIC,
		Tween.EASE_IN
	)
	tween.start()
	print("Reached goal timer started.")
	yield(get_tree().create_timer(2.0), "timeout")
	print("RG Timer ended.")
	Main.advance_level($Player/Starship.health, $Player/Starship.energy)
	Main.change_level("InBetweenLevels")


func _on_Starship_died():
	$HUD/Tween.interpolate_property($HUD/Lives, "position", Vector2(0, -20), Vector2.ZERO, 0.5, Tween.TRANS_BOUNCE)
	$HUD/Tween.start()
	$HUD/Lives/AnimationPlayer.play("lives"+str(Main.lives-1))
	print("Death timer started.")
	yield(get_tree().create_timer(2.0), "timeout")
	print("Death timer ended.")
	Main.lose_life()
	if Main.lives > 0:
		Main.reload_current_level()


func activate_insert(insert):
	match insert:
		"launching":
			print("launching insert")
			$Player.activate_launching_controller()
		"navigating":
			print("navigation insert")
			$Player.activate_navigating_controller()
		"repairing":
			print("repair insert")
		_: 
#			Default is empty
			print("empty insert")
			$Player.activate_empty_controller()


func set_aiming(direction):
	if direction == "left":
		print("aim left")
		$Player._change_launch_angle($Player/Starship.launch_angle -5)
	else:
		print("aim right")
		$Player._change_launch_angle($Player/Starship.launch_angle +5)
		


func set_power(new_power):
	print("set_power ", new_power)
	$Player._change_launch_power(new_power)
	
	
func set_engage():
	print("engage")
	$Player/Starship.launch()


func set_scope(x, y):
	print("scope")
	change_navigation_target(x, y)


func bolt_incremented(bolt_position):
	print("repair bolt ", bolt_position)
	


func change_navigation_target(x, y):
	var new_y = range_lerp(
		100 - y,
		0,
		100,
		$MapCamera2D.limit_top,
		$MapCamera2D.limit_bottom - 400 * $MapCamera2D.zoom.y
	)
	var new_x = range_lerp(
		x,
		0,
		100,
		$MapCamera2D.limit_left,
		$MapCamera2D.limit_right - 800 * $MapCamera2D.zoom.x
	)
	map_camera_target.x = new_x
	map_camera_target.y = new_y

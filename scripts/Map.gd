extends Node2D

export var area_bounds: Rect2
export var map_camera_smooth: float = 2.0
var map_camera_target: Vector2
export var map_index = 0


func _ready():
	load_controller_from_js()
	Main.current_level = map_index
	$PlaybackSystem.prepare_player_and_ships(map_index)
	get_tree().call_group("gravity_attractor", "add_body", $Player/Starship)
	$Player/Starship.connect("goal_reached", self, "_on_Starship_goal_reached")
	$Player/Starship.connect("health_changed", self, "_on_Starship_health_changed")
	$Player/Starship.connect("energy_changed", self, "_on_Starship_energy_changed")
	$Player/Starship.connect("died", self, "_on_Starship_died")
	$HUD/Lives/AnimationPlayer.play("lives"+str(Main.lives))
	$HUD/EnergyGUI/EnergyBarOverlay/AnimationPlayer.play("energy")
	$HUD/HealthGUI/HealthBarOverlay/AnimationPlayer.play("health")
	$HUD/CriticalHealth.visible = false
	$HUD/CriticalHealth/AnimationPlayer.play("critical_health")
	$HUD/CriticalEnergy.visible = false
	$HUD/CriticalEnergy/AnimationPlayer.play("critical_energy")



func load_controller_from_js():
	if OS.has_feature("HTML5"):
		var insert:String = $Player/JSBridge.js_call("getInsert")
		print("REFRESHED INSERT:", insert)
		activate_insert(insert)
#		$Player/Starship.controller = Starship.Controller.keys().find(insert.to_upper())
		

func _process(delta):
	if $MapCamera2D.current:
		$MapCamera2D.offset = lerp(
			$MapCamera2D.offset, map_camera_target, delta * map_camera_smooth
		)
	var target_pos = $Player/Starship.position
	#$GameplayCamera2D.position = target_pos + Vector2(0, -25)
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
	$Player/Starship.can_be_killed = false
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
	# Minimum amountsto carry over for the next level
	$Player/Starship.health = clamp($Player/Starship.health, Starship.CRITICAL_HEALTH + 10, Starship.HEALTH_MAX)
	$Player/Starship.energy = clamp($Player/Starship.energy, Starship.CRITICAL_ENERGY + 10, Starship.ENERGY_MAX)
	Main.advance_level($Player/Starship.health, $Player/Starship.energy)
	Main.change_level("InBetweenLevels")


func _on_Starship_health_changed(_value, old = 0):
	var diff = floor(old) - floor(_value)
	if diff > 0 and diff <= 1:
#if old - _value > 0 and old % floor(_value) > 0:
		$GameplayCamera2D.add_trauma(0.6)
		$HUD/Tween.interpolate_property($HUD/HealthGUI, "scale", Vector2(1.3,1.3), Vector2(1, 1), 0.3, Tween.TRANS_BACK)
		$HUD/Tween.start()
	$HUD/CriticalHealth.visible = true if _value <= $Player/Starship.CRITICAL_HEALTH else false


func _on_Starship_energy_changed(_value, old = 0):
	var diff = floor(old) - floor(_value)
	if diff > 0 and diff <= 1:
		$GameplayCamera2D.add_trauma(0.6)
		$HUD/Tween.interpolate_property($HUD/EnergyGUI, "scale", Vector2(1.3,1.3), Vector2(1, 1), 0.3, Tween.TRANS_BACK)
		$HUD/Tween.start()
	$HUD/CriticalEnergy.visible = true if _value <= $Player/Starship.CRITICAL_ENERGY else false



func _on_Starship_died():
	$GameplayCamera2D.add_trauma(1)
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
			$Player.activate_repairing_controller()
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
	if bolt_position == "left":
		$Player/Controllers/Repairing.activate_bolt1()
	else:
		$Player/Controllers/Repairing.activate_bolt2()


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


func _on_Starship_launched(launch_count):
	$GameplayCamera2D.add_trauma(0.2)
	pass # Replace with function body.


func _on_Starship_landed(landing_speed):
	$GameplayCamera2D.add_trauma(0.0015 * landing_speed)	
	pass # Replace with function body.

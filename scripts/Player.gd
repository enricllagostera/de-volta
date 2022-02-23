extends Node2D

const ANGLE_INCREMENT_PER_PRESS = 10
const ANGLE_MAX = 80
const ANGLE_MIN = -80
const POWER_INCREMENT_PER_PRESS = 10
const POWER_MIN = 0
const POWER_MAX = 100


func _ready():
	_change_launch_angle(0)
	_change_launch_power(0)
	activate_launching_controller()
	$Controllers/Navigating/NavHSlider.value = 50
	$Controllers/Navigating/NavVSlider.value = 50
	$Controllers/Flying/BoostButton.connect("pressed", self, "_on_boost_click")
	$JSBridge.js_call("testFunction")


func _input(_event):
#	Keyboard controls
	if Input.is_action_just_pressed("empty_controller"):
		activate_empty_controller()
	if Input.is_action_just_pressed("launching_controller"):
		activate_launching_controller()


func _process(delta):
	match $Starship.controller:
		Starship.Controller.FLYING:
			$Controllers/Empty.visible = false
			_flying(delta)
		Starship.Controller.LAUNCHING:
			$Controllers/Empty.visible = false
			_launching(delta)
		Starship.Controller.EMPTY:
			$Controllers/Empty.visible = true


func _flying(delta):
	$Controllers/Flying/BoostButton.disabled = not $Starship.can_boost()
	$Controllers/Flying/ShieldButton.disabled = not $Starship.can_shield(delta)
	$Controllers/Flying/ShieldButton.pressed = $Starship.is_shielded
	pass


func _launching(_delta):
	if $Starship.is_grounded:
		$Controllers/Launching.visible = true
		# Navigation mode
		# if Input.is_action_just_pressed("ui_accept"):
		# 	_change_navigation_mode(true)
		# elif Input.is_action_just_released("ui_accept"):
		# 	_change_navigation_mode(false)
		# Angle processing
		if Input.is_action_just_pressed("ui_left"):
			_change_launch_angle($Starship.launch_angle - ANGLE_INCREMENT_PER_PRESS)
		if Input.is_action_just_pressed("ui_right"):
			_change_launch_angle($Starship.launch_angle + ANGLE_INCREMENT_PER_PRESS)
		#	Power processing
		if Input.is_action_just_pressed("ui_up"):
			_change_launch_power($Starship.launch_power - POWER_INCREMENT_PER_PRESS)
		if Input.is_action_just_pressed("ui_down"):
			_change_launch_power($Starship.launch_power + POWER_INCREMENT_PER_PRESS)
		$Controllers/Launching/EngageButton.disabled = not $Starship.has_enough_energy_to_launch()
	else:
		$Controllers/Launching.visible = false


func _change_navigation_mode(new_state):
	$Starship.is_navigating = new_state
	$Starship.emit_signal("navigation_engaged", new_state)
	# $Controllers/Launching/NavigationToggle.pressed = new_state


func _change_launch_power(new_value):
	$Starship.launch_power = clamp(new_value, POWER_MIN, POWER_MAX)
	$Controllers/Launching/PowerHSlider.value = $Starship.launch_power
	$Controllers/Launching/PowerLbl.text = "Power: %d" % $Starship.launch_power


func _change_launch_angle(new_value):
	$Starship.launch_angle = clamp(new_value, ANGLE_MIN, ANGLE_MAX)
	$Controllers/Launching/AngleHSlider.value = $Starship.launch_angle
	$Controllers/Launching/AngleLbl.text = "Angle: %d" % $Starship.launch_angle


func _on_boost_click():
	$Starship.boost()


func _on_AngleHSlider_value_changed(value):
	_change_launch_angle(value)


func _on_PowerHSlider_value_changed(value):
	_change_launch_power(value)


func _on_EngageButton_pressed():
	$Starship.launch()
	_change_launch_angle(0)
	_change_launch_power(0)


func _on_NavigationToggle_toggled(button_pressed):
	$Starship.is_navigating = button_pressed
	$Starship.emit_signal("navigation_engaged", button_pressed)


func _on_Starship_navigation_engaged(_is_active):
	#	$Controllers/Launching/NavigationToggle.pressed = is_active
	pass


func _on_EmptyButton_pressed():
	activate_empty_controller()


func _on_LauncherButton_pressed():
	activate_launching_controller()


func _on_FlyingButton_pressed():
	activate_flying_controller()


func _on_BeholderInput_launching_insert_detected():
	if $Starship.controller != $Starship.Controller.LAUNCHING:
		activate_launching_controller()


func _on_BeholderInput_no_insert_detected():
	if $Starship.controller != $Starship.Controller.EMPTY:
		activate_empty_controller()


func activate_launching_controller(_args = null):
	$Controllers/Launching.visible = true
	$Controllers/Flying.visible = false
	$Controllers/Navigating.visible = false
	$Starship.controller = $Starship.Controller.LAUNCHING
	_change_navigation_mode(false)


func activate_empty_controller(_args = null):
	$Controllers/Launching.visible = false
	$Controllers/Navigating.visible = false
	$Controllers/Flying.visible = false
	$Starship.controller = $Starship.Controller.EMPTY
	_change_navigation_mode(false)


func activate_flying_controller(_args = null):
	$Controllers/Launching.visible = false
	$Controllers/Flying.visible = true
	$Controllers/Navigating.visible = false
	$Starship.controller = $Starship.Controller.FLYING
	_change_navigation_mode(false)


func activate_navigating_controller(_args = null):
	$Controllers/Launching.visible = false
	$Controllers/Flying.visible = false
	$Controllers/Navigating.visible = true
	$Starship.controller = $Starship.Controller.NAVIGATING
	_change_navigation_mode(true)


func _on_ShieldButton_toggled(button_pressed):
	$Starship.is_shielded = button_pressed
	$Starship/Shield.visible = button_pressed


func _on_NavigatingButton_pressed():
	activate_navigating_controller()

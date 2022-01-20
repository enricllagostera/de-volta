extends Node2D

const ANGLE_INCREMENT_PER_PRESS = 10;
const ANGLE_MAX = 80;
const ANGLE_MIN = -80;
const POWER_INCREMENT_PER_PRESS = 10;
const POWER_MIN = 0;
const POWER_MAX = 100;


func _ready():
	_change_launch_angle(0);
	_change_launch_power(0);
	_activate_empty_controller();


func _input(_event):
	if Input.is_action_just_pressed("empty_controller"):
		_activate_empty_controller();
	if Input.is_action_just_pressed("launching_controller"):
		_activate_launching_controller();


func _process(delta):
	if $Starship.controller == $Starship.Controller.LAUNCHING and $Starship.is_grounded:
		$Controllers/Launching.visible = true;
		# Navigation mode
		if Input.is_action_just_pressed("ui_accept"):
			_change_navigation_mode(true);
		elif Input.is_action_just_released("ui_accept"):
			_change_navigation_mode(false);
		# Angle processing
		if Input.is_action_just_pressed("ui_left"):
				_change_launch_angle($Starship.launch_angle - ANGLE_INCREMENT_PER_PRESS);
		if Input.is_action_just_pressed("ui_right"):
			_change_launch_angle($Starship.launch_angle + ANGLE_INCREMENT_PER_PRESS);
		#	Power processing
		if Input.is_action_just_pressed("ui_up"):
				_change_launch_power($Starship.launch_power - POWER_INCREMENT_PER_PRESS);
		if Input.is_action_just_pressed("ui_down"):
			_change_launch_power($Starship.launch_power + POWER_INCREMENT_PER_PRESS);
		$Controllers/Launching/EngageButton.disabled = not $Starship.has_enough_energy_to_launch();
	else:
		$Controllers/Launching.visible = false;


func _change_navigation_mode(new_state):
	$Starship.is_navigating = new_state;
	$Starship.emit_signal("navigation_engaged", new_state);
	$Controllers/Launching/NavigationToggle.pressed = new_state;


func _change_launch_power(new_value):
	$Starship.launch_power = clamp(new_value, POWER_MIN, POWER_MAX);
	$Controllers/Launching/PowerHSlider.value = $Starship.launch_power;
	$Controllers/Launching/PowerLbl.text = "Power: %d" % $Starship.launch_power;


func _change_launch_angle(new_value):
	$Starship.launch_angle = clamp(new_value, ANGLE_MIN, ANGLE_MAX);
	$Controllers/Launching/AngleHSlider.value = $Starship.launch_angle;
	$Controllers/Launching/AngleLbl.text = "Angle: %d" % $Starship.launch_angle;


func _on_AngleHSlider_value_changed(value):
	_change_launch_angle(value)


func _on_PowerHSlider_value_changed(value):
	_change_launch_power(value)


func _on_EngageButton_pressed():
	$Starship._launch();
	_change_launch_angle(0);
	_change_launch_power(0);


func _on_NavigationToggle_toggled(button_pressed):
	$Starship.is_navigating = button_pressed;
	$Starship.emit_signal("navigation_engaged", button_pressed);


func _on_Starship_navigation_engaged(is_active):
	$Controllers/Launching/NavigationToggle.pressed = is_active;


func _on_EmptyButton_pressed():
	_activate_empty_controller();


func _on_LauncherButton_pressed():
	_activate_launching_controller();


func _on_BeholderInput_launching_insert_detected():
	if $Starship.controller != $Starship.Controller.LAUNCHING:
		_activate_launching_controller();


func _on_BeholderInput_no_insert_detected():
	if $Starship.controller != $Starship.Controller.EMPTY:
		_activate_empty_controller();


func _activate_launching_controller(_args = null):
	$Controllers/Empty.visible = false;
	$Controllers/Launching.visible = true;
	$Starship.controller = $Starship.Controller.LAUNCHING;


func _activate_empty_controller(_args = null):
	$Controllers/Empty.visible = true;	
	$Controllers/Launching.visible = false;
	$Starship.controller = $Starship.Controller.EMPTY;
	$Starship.is_navigating = false;
	$Starship.emit_signal("navigation_engaged", false);

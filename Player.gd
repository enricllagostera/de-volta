extends Node2D

const ANGLE_INCREMENT_PER_PRESS = 10;
const ANGLE_MAX = 80;
const ANGLE_MIN = -80;
const POWER_INCREMENT_PER_PRESS = 10;
const POWER_MIN = 0;
const POWER_MAX = 100;

var launch_angle = 0.0
var launch_power = 0.0;


func _ready():
	$Controllers/Empty.visible = true;
	$Controllers/Launching.visible = false;
	$Starship.controller = $Starship.Controller.EMPTY;
	_change_launch_angle(0);
	_change_launch_power(0);


func _input(_event):
	if Input.is_action_just_pressed("empty_controller"):
		$Controllers/Empty.visible = true;
		$Controllers/Launching.visible = false;
		$Starship.controller = $Starship.Controller.EMPTY;
	if Input.is_action_just_pressed("launching_controller"):
		$Controllers/Empty.visible = false;
		$Controllers/Launching.visible = true;
		$Starship.controller = $Starship.Controller.LAUNCHING;
		

func _process(delta):
	if $Starship.controller == $Starship.Controller.LAUNCHING and $Starship.is_grounded:
		$Controllers/Launching.visible = true;
		$Starship/LaunchAim.visible = true;		
		# Navigation mode
		if Input.is_action_just_pressed("ui_accept"):
			$Starship.is_navigating = true;
			$Starship.emit_signal("navigation_engaged", true);
		elif Input.is_action_just_released("ui_accept"):
			$Starship.is_navigating = false;
			$Starship.emit_signal("navigation_engaged", false);
		$Controllers/Launching/NavigationToggle.pressed = $Starship.is_navigating;
		if $Starship.is_navigating:
			$Starship._change_energy($Starship.energy - delta * $Starship.energy_for_navigation_per_s);
		# Angle processing
		if Input.is_action_just_pressed("ui_left"):
				_change_launch_angle(launch_angle - ANGLE_INCREMENT_PER_PRESS);
		if Input.is_action_just_pressed("ui_right"):
			_change_launch_angle(launch_angle + ANGLE_INCREMENT_PER_PRESS);
		$Starship/LaunchAim.rotation = $Starship/Visual.rotation + deg2rad(launch_angle - 90);
		#	Power processing
		if Input.is_action_just_pressed("ui_up"):
				_change_launch_power(launch_power - POWER_INCREMENT_PER_PRESS);
		if Input.is_action_just_pressed("ui_down"):
			_change_launch_power(launch_power + POWER_INCREMENT_PER_PRESS);
		var points = $Starship/LaunchAim/Power.points;
		points.set(0, Vector2.ZERO);
		points.set(1, Vector2(launch_power, 0));
		$Starship/LaunchAim/Power.points = points;
		if $Starship.energy < (launch_power * $Starship.energy_per_launch_power_rate):
			$Starship/LaunchAim/Power.default_color = Color.black;
			$Controllers/Launching/EngageButton.disabled = true;
		else:
			$Starship/LaunchAim/Power.default_color = Color.white;
			$Controllers/Launching/EngageButton.disabled = false;
	else:
		$Starship/LaunchAim.visible = false;
		$Controllers/Launching.visible = false;


func _change_launch_power(new_value):
		launch_power = clamp(new_value, POWER_MIN, POWER_MAX);
		$Controllers/Launching/PowerHSlider.value = launch_power;
		$Controllers/Launching/PowerLbl.text = "Power: %d" % launch_power;


func _change_launch_angle(new_value):
		launch_angle = clamp(new_value, ANGLE_MIN, ANGLE_MAX);
		$Controllers/Launching/AngleHSlider.value = launch_angle;
		$Controllers/Launching/AngleLbl.text = "Angle: %d" % launch_angle;


func _on_AngleHSlider_value_changed(value):
	_change_launch_angle(value)


func _on_PowerHSlider_value_changed(value):
	_change_launch_power(value)


func _on_EngageButton_pressed():
	$Starship._launch(launch_power/100);


func _on_NavigationToggle_toggled(button_pressed):
	$Starship.is_navigating = button_pressed;
	$Starship.emit_signal("navigation_engaged", button_pressed);


func _on_Starship_navigation_engaged(is_active):
	$Controllers/Launching/NavigationToggle.pressed = is_active;


func _on_EmptyButton_pressed():
	$Controllers/Empty.visible = true;
	$Controllers/Launching.visible = false;
	$Starship.controller = $Starship.Controller.EMPTY;
	$Starship.is_navigating = false;
	$Starship.emit_signal("navigation_engaged", false);


func _on_LauncherButton_pressed():
	$Controllers/Empty.visible = false;
	$Controllers/Launching.visible = true;
	$Starship.controller = $Starship.Controller.LAUNCHING;

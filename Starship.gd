extends KinematicBody2D

const ENERGY_MAX = 100.0;
const HEALTH_MAX = 100.0;
const ENERGY_MIN = 1.0;
const HEALTH_MIN = 1.0;
const OFFSCREEN_TIME_MAX = 3.0;

export var base_power = 40.0;
export var base_damp = 0.001;
export var base_gravity = 20;
export var velocity_damage_rate = 0.1;
export var energy_per_launch_power_rate = 40.0;
export var energy_per_battery = 30.0;
export var energy_for_navigation_per_s = 0.5;

var launch_count = 0;
var energy = 100;
var health = 100;
var velocity;
var last_launch_direction = Vector2.UP;
var is_grounded = false;
var is_navigating = false;

signal energy_changed(new_energy);
signal launched(launch_count);
signal health_changed(new_health);
signal died();
signal goal_reached(launch_count, energy);
signal navigation_engaged(is_active);


func _ready():
	velocity = Vector2.ZERO;
	is_grounded = false;


func _process(delta):
	var mouse_pos = get_global_mouse_position();
	$LaunchAim.look_at(mouse_pos);
	var launch_power = _get_launch_power()
	if is_grounded:
		$LaunchAim.visible = true;
		var points = $LaunchAim/Power.points;
		points.set(0, Vector2.ZERO);
		points.set(1, Vector2(20 + launch_power * 80, 0));
		$LaunchAim/Power.points = points;
		if energy < _get_launch_power() * energy_per_launch_power_rate:
			$LaunchAim/Power.default_color = Color.black;
		else:
			$LaunchAim/Power.default_color = Color.white;
		if is_navigating:
			_change_energy(energy - delta * energy_for_navigation_per_s);
			
	else:
		$LaunchAim.visible = false;


func _input(event):
	if is_grounded:
		if event is InputEventMouseButton:
			if event.pressed:
				_launch(_get_launch_power());
		if Input.is_action_just_pressed("ui_up"):
			is_navigating = true;
			emit_signal("navigation_engaged", true);
		elif Input.is_action_just_released("ui_up"):
			is_navigating = false;
			emit_signal("navigation_engaged", false);
			


func _physics_process(delta):
	if not is_grounded:
#		velocity += Vector2.DOWN * base_gravity;
		velocity += -velocity * base_damp;
	else:
		velocity = Vector2.ZERO;
	var collision = move_and_collide(velocity * delta);
	if collision:
		# Land perpendicular to the surface
		$Visual.rotation = get_angle_to(position + collision.normal) + deg2rad(90);
		is_grounded = true;
		health -= velocity.length() * velocity_damage_rate;
		emit_signal("health_changed", health);
		if health <= HEALTH_MIN:
			emit_signal("died");
			visible = false;


func _launch(power):
	if energy < power * energy_per_launch_power_rate:
		return;
	var launch_direction = _get_launch_direction();
	velocity += launch_direction * power * base_power;
	last_launch_direction = launch_direction;
	$Visual.rotation = get_angle_to(position + last_launch_direction) + deg2rad(90);
	is_grounded = false;
	_change_energy(energy + -power * energy_per_launch_power_rate);
	launch_count += 1;
	emit_signal("launched", launch_count);


# Point of change for direction input
func _get_launch_direction():
	return (get_global_mouse_position() - position).normalized();


func _get_launch_power():
	var mouse_pos = get_global_mouse_position();
	var distance_to_mouse = position.distance_to(mouse_pos);
	var launch_power = clamp(
		range_lerp(distance_to_mouse, 40, 200, 0.0, 1.0), 
		0, 1.0);
	return launch_power;


func collect_battery():
	_change_energy(energy + energy_per_battery);


func _on_Goal_body_entered(body):
	if body == self:
		$VisibilityNotifier2D.free()
		emit_signal("goal_reached", launch_count, energy);


func _change_energy(new_energy):
	energy = clamp(new_energy, ENERGY_MIN, ENERGY_MAX);
	emit_signal("energy_changed", energy);


func pull(force):
	velocity += force;


func _on_VisibilityNotifier2D_screen_exited():
	$OffscreenTimer.wait_time = OFFSCREEN_TIME_MAX;
	$OffscreenTimer.start();


func _on_VisibilityNotifier2D_screen_entered():
	$OffscreenTimer.stop();
	$OffscreenTimer.wait_time = OFFSCREEN_TIME_MAX;


func _on_OffscreenTimer_timeout():
	$VisibilityNotifier2D.free()
	emit_signal("died")

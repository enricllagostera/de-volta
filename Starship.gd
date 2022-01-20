extends KinematicBody2D

const ENERGY_MAX = 100.0;
const HEALTH_MAX = 100.0;
const ENERGY_MIN = 1.0;
const HEALTH_MIN = 1.0;
const OFFSCREEN_TIME_MAX = 1.0;

enum Controller{
	EMPTY,
	LAUNCHING,
	FLYING,
	REPAIRING
}

export var base_power = 1.0;
export var base_damp = 0.001;
export var base_gravity = 20;
export var velocity_damage_rate = 0.1;
export var energy_per_launch_power_rate = 0.004;
export var energy_per_battery = 30.0;
export var energy_for_navigation_per_s = 0.5;

var controller = Controller.EMPTY;
var launch_count = 0;
var launch_angle = 0;
var launch_power = 0;
var energy = 100;
var health = 100;
var velocity;
var last_launch_direction = Vector2.UP;
var is_grounded = false;
var is_navigating = false;
var is_offscreen = false;
var is_dying = false;

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
	if is_dying:
		$LaunchAim.visible = false;
	match controller:
		Controller.LAUNCHING:
			launching(delta)
		Controller.EMPTY:
			Engine.time_scale = 0.1;
			$LaunchAim.visible = false;


func launching(delta):
	Engine.time_scale = 1.0;
	if controller == Controller.LAUNCHING and is_grounded:
		$LaunchAim.visible = true;
		$LaunchAim.rotation = $Visual.rotation + deg2rad(launch_angle - 90);
		if is_navigating:
			_change_energy(energy - delta * energy_for_navigation_per_s);
		display_launch_aim();
	else:
		$LaunchAim.visible = false;


func _physics_process(delta):
	if not is_grounded:
		velocity += -velocity * base_damp;
	else:
		velocity = Vector2.ZERO;
	var collision = move_and_collide(velocity * delta);
	if collision:
		# Always land perpendicular to the collision surface
		$Visual.rotation = get_angle_to(position + collision.normal) + deg2rad(90);
		is_grounded = true;
		health -= velocity.length() * velocity_damage_rate;
		emit_signal("health_changed", health);
		if health <= HEALTH_MIN and not is_dying:
			emit_signal("died");
			is_dying = true;
			$DeathExplosion.emitting = true;
			$Visual.visible = false;
			$LaunchAim.visible = false;	


func _launch():
	if not has_enough_energy_to_launch():
		return;
	is_navigating = false;
	emit_signal("navigation_engaged", false);
	var launch_direction = global_position.direction_to($LaunchAim/Tip.global_position);
	velocity += launch_direction * (launch_power * base_power);
	last_launch_direction = launch_direction;
	$Visual.rotation = get_angle_to(position + last_launch_direction) + deg2rad(90);
	is_grounded = false;
	_change_energy(energy + -launch_power * energy_per_launch_power_rate);
	launch_count += 1;
	emit_signal("launched", launch_count);


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


func has_enough_energy_to_launch():
	return energy >= (launch_power * energy_per_launch_power_rate)


func display_launch_aim():
	var points = $LaunchAim/Power.points;
	points.set(0, Vector2.ZERO);
	points.set(1, Vector2(launch_power, 0));
	$LaunchAim/Power.points = points;
	if has_enough_energy_to_launch():
		$LaunchAim/Power.default_color = Color.white;
	else:
		$LaunchAim/Power.default_color = Color.black;	


func entered_screen():
	is_offscreen = false;


func exited_screen():
	if is_offscreen:
		return;
	is_offscreen = true;
	yield(get_tree().create_timer(OFFSCREEN_TIME_MAX), "timeout");
	if is_offscreen:
		emit_signal("died")

extends KinematicBody2D
class_name Starship

const ENERGY_MAX = 100.0
const HEALTH_MAX = 100.0
const ENERGY_MIN = 1.0
const HEALTH_MIN = 1.0
const OFFSCREEN_TIME_MAX = 1.0
const SHIELD_PROTECTION_RATE = 0.8
const CRITICAL_ENERGY = 10
const CRITICAL_HEALTH = 10

enum Controller { EMPTY, LAUNCHING, FLYING, REPAIRING, NAVIGATING }

export var base_power = 1.0
export var base_damp = 0.001
export var base_gravity = 20
export var velocity_damage_rate = 0.05
export var energy_per_launch_power_rate = 0.004
export var energy_per_shield_rate = 5
export var energy_per_boost = 10
export var energy_per_battery = 30.0
export var energy_for_navigation_per_s = 0.5
export var critical_energy_mod = 0.5
export var critical_health_mod = 0.5


onready var controller = Controller.LAUNCHING
var launch_count = 0
var launch_angle = 0
var launch_power = 0
var energy = 100
var health = 100
var velocity
var last_launch_direction = Vector2.UP
var is_grounded = false
var is_navigating = false
var is_out_of_bounds = false
var is_dying = false
var is_shielded = false
var out_of_bounds_timer: Timer
var can_be_killed = true

var is_critical_energy = false
var is_critical_health = false


signal energy_changed(new_energy, old_energy)
signal launched(launch_count)
signal health_changed(new_health, old_health)
signal landed(landing_speed)
signal died
signal goal_reached(launch_count, energy)
signal navigation_engaged(is_active)


func _ready():
	$Shield.visible = false
	velocity = Vector2.ZERO
	is_grounded = false
	can_be_killed = true
	_change_energy(Main.current_energy)
	_change_health(Main.current_health)
	


func _process(delta):
#	if $Visual.visible == false:
#		$LaunchAim.visible = false
	if is_dying:
		$LaunchAim.visible = false
		return
	match controller:
		Controller.LAUNCHING:
			launching(delta)
		Controller.FLYING:
			_flying(delta)
		Controller.REPAIRING:
			repairing()
		Controller.EMPTY:
			Engine.time_scale = 1.0
			$LaunchAim.visible = false


func _flying(_delta):
	Engine.time_scale = 1.0
	if is_grounded:
		is_shielded = false


func launching(_delta):
	Engine.time_scale = 1.0
	if controller == Controller.LAUNCHING and is_grounded:
		$LaunchAim.visible = true
		$LaunchAim.rotation = $Visual.rotation + deg2rad(launch_angle - 90)
		display_launch_aim()
	else:
		$LaunchAim.visible = false


func repairing():
	Engine.time_scale = 1.0
	$LaunchAim.visible = false
	if not is_grounded:
		return
	


func _physics_process(delta):
	if $Visual.visible == false:
		$LaunchAim.visible = false
	is_critical_energy = (energy <= CRITICAL_ENERGY)
	is_critical_health = (health <= CRITICAL_HEALTH)
	if is_dying or not can_be_killed:
		return
	if is_critical_health:
		_change_health(health - critical_health_mod*delta)
	if is_critical_energy:
		_change_energy(energy - critical_energy_mod*delta)
	if is_navigating:
		_change_energy(energy - delta * energy_for_navigation_per_s)
	if not is_grounded:
		velocity += -velocity * base_damp
		var target_rotation = get_angle_to(position + velocity) + deg2rad(90)
		$Visual.rotation = lerp_angle($Visual.rotation, target_rotation, delta * 3.0)
	else:
		velocity = Vector2.ZERO
	var collision = move_and_collide(velocity * delta)
	if collision and velocity.length() > 0.1:
		# First calculate landing damage, before changing is_grounded
		var damage = velocity.length() * velocity_damage_rate
		var apply_damage = 0
		if is_shielded:
			apply_damage = damage * (1.0 - SHIELD_PROTECTION_RATE)
		else:
			apply_damage = damage 
		# Always land perpendicular to the collision surface
		$Visual.rotation = get_angle_to(position + collision.normal) + deg2rad(90)
		is_grounded = true
		$Visual/AnimationPlayer.play("landing")
		$Visual/AnimationPlayer.queue("grounded")
		emit_signal("landed", velocity.length())
		# Apply health change consequences
		_change_health(health - apply_damage)
		if health <= HEALTH_MIN:
			start_dying()


func start_dying():
	if is_dying:
		return;
	is_dying = true
	$DeathExplosion.emitting = true
	$Visual.visible = false
	$LaunchAim.visible = false
	emit_signal("died")


func launch():
	if not has_enough_energy_to_launch() or not is_grounded:
		return
	emit_signal("navigation_engaged", false)
	var launch_direction = global_position.direction_to($LaunchAim/Tip.global_position)
	velocity += launch_direction * (launch_power * base_power)
	last_launch_direction = launch_direction
	$Visual.rotation = get_angle_to(position + last_launch_direction) + deg2rad(90)
	is_grounded = false
	_change_energy(energy + -launch_power * energy_per_launch_power_rate)
	launch_count += 1
	$Visual/Particles2D.lifetime = 2
	$Visual/Particles2D.restart()
	$Visual/Particles2D.emitting = true
	$Visual/AnimationPlayer.play("flying")
	emit_signal("launched", launch_count)


func collect_battery():
	_change_energy(energy + energy_per_battery)


func _on_Goal_body_entered(body):
	if body == self:
		emit_signal("goal_reached", launch_count, energy)


func _change_energy(new_energy):
	if new_energy <= ENERGY_MIN:
		energy = 0
		emit_signal("energy_changed", 0, 0)
		start_dying()
		return
	var old_energy = energy
	energy = clamp(new_energy, ENERGY_MIN, ENERGY_MAX)
	emit_signal("energy_changed", energy, old_energy)


func _change_health(new_health):
	if new_health <= HEALTH_MIN:
		health = 0
		emit_signal("health_changed", 0, 0)
		start_dying()
		return
	var old_health = health
	health = clamp(new_health, HEALTH_MIN, HEALTH_MAX)
	emit_signal("health_changed", health, old_health)


func pull(force):
	velocity += force


func has_enough_energy_to_launch():
	return energy >= (launch_power * energy_per_launch_power_rate)


func can_boost():
	return (not is_grounded) and (energy >= energy_per_boost)
	
	
func boost():
	if energy >= energy_per_boost:
		velocity = velocity * 1.5
		_change_energy(energy - energy_per_boost)
		$Visual/Particles2D.lifetime = 0.5
		$Visual/Particles2D.restart()
		$Visual/Particles2D.emitting = true


func can_shield(delta):
	return (not is_grounded) and (energy >= energy_per_shield_rate * delta)


func display_launch_aim():
	if(launch_power > 0):
		$LaunchAim.visible = true
		var points = $LaunchAim/Power.points
		points.set(0, Vector2.ZERO)
		points.set(1, Vector2(40 + launch_power, 0))
		$LaunchAim/Power.points = points
		if has_enough_energy_to_launch():
			$LaunchAim/Power.default_color = Color.white
		else:
			$LaunchAim/Power.default_color = Color.black
		$LaunchAim/Tip.position.x = 40 + launch_power + 5
		$LaunchAim/MaxTip.position.x = 40 + (100) + 5
	else:
		$LaunchAim.visible = false


func entered_map_area():
	is_out_of_bounds = false


func exited_map_area():
	if is_out_of_bounds:
		return
	is_out_of_bounds = true
	yield(get_tree().create_timer(OFFSCREEN_TIME_MAX), "timeout")
	if is_out_of_bounds:
		emit_signal("died")


func touched_ghost(_ghost):
	is_dying = true
	$DeathExplosion.emitting = true
	$Visual.visible = false
	$LaunchAim.visible = false
	emit_signal("died")

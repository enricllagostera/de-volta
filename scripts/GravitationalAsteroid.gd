extends Node2D

export var mass = 200.0
var attracted = []
export var line_width_min = 0
export var line_width_max = 40
onready var points = PoolVector2Array()


func _process(delta):
	for body in attracted:
		var attraction = mass * mass / global_position.distance_squared_to(body.global_position)
		var direction = (global_position - body.global_position).normalized()
		body.pull(direction * attraction * delta)
		points = PoolVector2Array()
		points.append(Vector2.ZERO)
		points.append(body.global_position - global_position)
		if has_node("Line2D"):
			$Line2D.width = clamp((direction * attraction).length(), line_width_min, line_width_max)
			$Line2D.points = points


func add_body(new_body):
	attracted.append(new_body)

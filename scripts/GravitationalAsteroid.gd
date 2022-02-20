extends StaticBody2D

export var mass = 200.0
var attracted = []
onready var points = PoolVector2Array()


func _process(delta):
	for body in attracted:
		var attraction = mass * mass / position.distance_squared_to(body.position)
		var direction = (position - body.position).normalized()
		body.pull(direction * attraction * delta)
		points = PoolVector2Array()
		points.append(Vector2.ZERO)
		points.append(body.position - position)
		if $Line2D:
			# print((direction * attraction).length())
			$Line2D.width = (direction * attraction).length()
			$Line2D.points = points


func add_body(new_body):
	attracted.append(new_body)

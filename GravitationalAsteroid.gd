extends StaticBody2D

export var mass = 200.0;
var attracted = []


func _process(delta):
	for body in attracted:
		var attraction = mass * mass / position.distance_squared_to(body.position);
		var direction = (position - body.position).normalized();
		body.pull(direction * attraction * delta);


func add_body(new_body):
	attracted.append(new_body);

extends Area2D

func _ready():
	connect("body_entered", self, "_on_Battery_body_entered")
	$Visual/AnimationPlayer.play("default")


func _on_Battery_body_entered(body):
	if body.is_in_group("starship"):
		body.collect_battery()
		self.queue_free()

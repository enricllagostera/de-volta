extends Area2D


func _on_Battery_body_entered(body):
	if body.is_in_group("starship"):
		body.collect_battery()
		self.queue_free()

extends Polygon2D

export(Vector2) var offset_per_second = Vector2.ONE


func _process(delta):
	texture_offset += delta * offset_per_second

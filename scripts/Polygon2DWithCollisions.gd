extends Polygon2D

export var offset_speed = 1.0


func _ready():
	var poly = self.get_node("StaticBody2D/CollisionPolygon2D")
	poly.set_polygon(polygon)
	$Line2D.points = poly.polygon
	$Line2D.add_point(poly.polygon[0])


func _process(delta):
	texture_offset.x += delta * offset_speed

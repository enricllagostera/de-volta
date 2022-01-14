extends Polygon2D

func _ready():
	var poly = self.get_node("StaticBody2D/CollisionPolygon2D")
#	poly.position = position
	poly.set_polygon(polygon);
	


extends Timer

func _ready():
	pass


func _on_VisibilityNotifier2D_screen_exited():
	start()

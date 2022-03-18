extends Sprite

func _ready():
	$AnimationPlayer.play("title")
	$StartButton.connect("pressed", self, "on_start_new_game")


func on_start_new_game():
	Main.change_level("Level1")

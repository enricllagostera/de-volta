extends Sprite


func _ready():
	$AnimationPlayer.play("title")
	$StartButton.connect("pressed", self, "on_start_new_game")
	$CreditsButton.connect("pressed", self, "on_credits")


func on_start_new_game():
	Main.change_level("Level1")


func on_credits():
	Main.change_level("CreditsScreen")

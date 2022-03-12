extends Node2D

func _ready():
	$PlayCountLbl.text = str(Main.play_count);
	$ContinueButton.connect("pressed", self, "restart_game");

func restart_game():
	Main.reset_game()
	Main.change_level("InBetweenLevels");

extends Node2D

func _ready():
	$CountLbl.text = str(Main.play_count);
	$Label2.text = "You got home " + str(Main.play_count) + ("time." if Main.play_count == 1 else "times.")
	$ContinueButton.connect("pressed", self, "restart_game");

func restart_game():
	Main.reset_game()
	Main.change_level("TitleScreen");

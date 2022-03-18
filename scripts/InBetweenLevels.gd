extends Node2D

var current_level = 0

func _ready():
	$CountLbl.text = str(Main.play_count);
	$Label2.text = "time." if Main.play_count == 1 else "times."
	$ContinueButton.connect("pressed", self, "load_next_level")
	$AnimationPlayer.play("between")


func load_next_level():
	if current_level >= Main.levels.size():
		current_level = 0
	Main.change_level(Main.levels[current_level].name)


extends Node2D

var current_level = 0

func _ready():
	$ContinueButton.connect("pressed", self, "load_next_level")
	$AnimationPlayer.play("between")


func load_next_level():
	Main.change_level("TitleScreen")


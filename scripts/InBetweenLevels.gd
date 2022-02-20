extends Node2D

var level_1
var level_2
var level_3
var current_level


func _ready():
	$PlayCountLbl.text = str(Main.play_count);
	render_levels()
	$ContinueButton.connect("pressed", self, "load_next_level")


func render_levels():
	var center_count = Main.play_count % 3
	$Level1/On.visible = false
	$Level2/On.visible = false
	$Level3/On.visible = false
	match center_count:
		1: 
			$Level1/On.visible = true
			$CurrentLevel.position = $Level2.position
			current_level = 1
		2: 
			$Level1/On.visible = true
			$Level2/On.visible = true
			$CurrentLevel.position = $Level3.position
			current_level = 2
		0: 
			if Main.play_count > 0:
				add_outer_ring()
				$Level1/On.visible = true
				$Level2/On.visible = true
				$Level3/On.visible = true
			$CurrentLevel.position = $Level1.position
			current_level = 0


func add_outer_ring():
	yield(get_tree().create_timer(2.0), "timeout")
	$Level1/On.visible = false
	$Level2/On.visible = false
	$Level3/On.visible = false



func load_next_level():
	Main.change_level(Main.levels[current_level].name)


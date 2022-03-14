extends Panel

var is_active = true;
var alignment_threshold = 8
var reset_threshold = 30

signal repaired


func _ready():
	reset_target()


func reset_target():
	# 68 - 208
	while $Pointer.position.distance_to($Target.position) <= reset_threshold:
		$Target.position.x = rand_range(68, 208)


func activate_bolt1():
	$Tween.interpolate_property($Bolt1, "scale", Vector2(0.8, 0.8), Vector2(0.59, 0.59), 0.3, Tween.TRANS_BACK)
	$Tween.start()
	$Pointer.position.x = clamp($Pointer.position.x - 5, 68, 208)
	check_alignment()


func activate_bolt2():
	$Tween.interpolate_property($Bolt2, "scale", Vector2(0.8, 0.8), Vector2(0.59, 0.59), 0.3, Tween.TRANS_BACK)	
	$Tween.start()	
	$Pointer.position.x = clamp($Pointer.position.x + 5, 68, 208)
	check_alignment()


func check_alignment():
	if $Pointer.position.distance_to($Target.position) <= alignment_threshold:
		print("ALIGNED!")
		emit_signal("repaired")
		$Tween.interpolate_property($Target, "scale", Vector2(1,1), Vector2(0.59, 0.59), 0.3, Tween.TRANS_BACK)
		$Tween.start()
		reset_target()


func _on_Bolt1Button_pressed():
	activate_bolt1()


func _on_Bolt2Button_pressed():
	activate_bolt2()

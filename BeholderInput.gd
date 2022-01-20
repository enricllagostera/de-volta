extends Node

var js_spaceHopper;
var cb_launching_insert_detected;
var cb_no_insert_detected;

signal launching_insert_detected();
signal no_insert_detected();


func _ready():
	js_spaceHopper = JavaScript.get_interface("spaceHopper");
	cb_launching_insert_detected = JavaScript.create_callback(self, 
			"launching_insert_detected");
	cb_no_insert_detected = JavaScript.create_callback(self, 
			"no_insert_detected");
	js_spaceHopper.initCallbacks(
			cb_launching_insert_detected,
			cb_no_insert_detected)


func _process(delta):
	js_spaceHopper.gameUpdate();


func no_insert_detected(args = null):
	emit_signal("no_insert_detected");


func launching_insert_detected(args = null):
	emit_signal("launching_insert_detected");

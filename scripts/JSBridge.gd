## Provides a Command-based interface for JS - Godot integration
extends Node

export(String) var js_object_name = "spaceHopper"
export(NodePath) var target

var js_obj
var cb_command
var target_node
var navigator


func _ready():
	if not OS.has_feature("HTML5"):
		set_process(false)
		return
	target_node = get_node(target)
	cb_command = JavaScript.create_callback(self, "_interpretCommand")
	js_obj = JavaScript.get_interface(js_object_name)
	js_obj.initCallbacks(cb_command)
	navigator = JavaScript.get_interface("navigator")


func _process(_delta):
	js_obj.gameUpdate()


# Public function that allows for calling functions on JS from
# other nodes
func js_call(function_name, args_array = []):
	if not OS.has_feature("HTML5"):
		return
	var fn = funcref(js_obj, function_name)
	fn.call_funcv(args_array)


# General callback for sending commands from JS to Godot.
# Commands have a `name` and an `args` array with arguments.
func _interpretCommand(args = null):
	var params = []
	if args.size() > 1:
		for i in range(1, args.size()):
			params.append(args[i])
	if target_node.has_method(args[0]):
		target_node.callv(args[0], params)
	else:
		print("ERROR: No %s on target node %s." % [args[0], str(target_node)])

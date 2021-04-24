extends Area2D

var _torso
var _label

export var text = ""

func _ready():
	_torso = get_tree().get_nodes_in_group("torso")[0]
	_label = get_tree().get_nodes_in_group("sign_label")[0]
	connect("body_entered", self, "_on_body_enter")
	connect("body_exited", self, "_on_body_exit")
	
func _on_body_enter(body):
	if body == _torso:
		_label.rect_position = global_position + get_viewport().canvas_transform.origin - _label.rect_size * 0.5
		_label.visible = true
		_label.text = text
		
func _on_body_exit(body):
	if body == _torso:
		_label.visible = false

func _process(delta):
	if _label.visible:
		_label.rect_position = global_position + get_viewport().canvas_transform.origin - _label.rect_size * 0.5

extends Area2D

var _torso
var _label
var _visible = false

export var text = ""

func _ready():
	_label = get_tree().get_nodes_in_group("sign_label")[0]
	connect("body_entered", self, "_on_body_enter")
	connect("body_exited", self, "_on_body_exit")
	
func _get_torso():
	if not is_instance_valid(_torso):
		var inGroup = get_tree().get_nodes_in_group("torso")
		if inGroup.size() > 0:
			_torso = get_tree().get_nodes_in_group("torso")[0]
		else:
			_torso = null
	return _torso
	
func _on_body_enter(body):
	if body == _get_torso():
		_label.rect_position = global_position + get_viewport().canvas_transform.origin - _label.rect_size * 0.5
		_label.visible = true
		_label.text = text
		_visible = true
		
		var player = get_tree().get_nodes_in_group("player")[0]
		player.set_checkpoint(self)
		
func _on_body_exit(body):
	if body == _get_torso():
		_label.visible = false
		_visible = false

func _process(delta):
	if _visible:
		_label.rect_position = global_position + get_viewport().canvas_transform.origin - _label.rect_size * 0.5

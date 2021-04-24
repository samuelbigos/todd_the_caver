extends Node2D

var _limbs = []
var _selectedLimb = null
var _signs = []

onready var _handLeft = get_node("ArmLeft/HandLeft")
onready var _torso = get_node("Torso")
onready var _head = get_node("Head")

onready var _armLeft = get_node("ArmLeft")
onready var _armRight = get_node("ArmRight")
onready var _legLeft = get_node("LegLeft")
onready var _legRight = get_node("LegRight")

onready var _signLabel = get_node("../CanvasLayer/Label")

func _ready():
	_limbs.append(_armLeft)
	_limbs.append(_armRight)
	_limbs.append(_legLeft)
	_limbs.append(_legRight)
	
	var playerCol = Color(1.0, 1.0, 1.0)
	_armLeft.defaultCol = playerCol
	_armRight.defaultCol = playerCol
	_legLeft.defaultCol = playerCol
	_legRight.defaultCol = playerCol
		
	for child in _torso.get_children():
		if child.get_class() == "Sprite":
			child.modulate = playerCol
			
	for child in _head.get_children():
		if child.get_class() == "Sprite" and not child.is_in_group("unshaded"):
			child.modulate = playerCol
		
func on_sign_exit(body):
	if body == self:
		_signLabel.visible = false
	
func _process(delta):
	if (Input.is_action_just_pressed("select_left_arm")):
		_armLeft.on_selected()
		_armRight.on_deselected()
		_legLeft.on_deselected()
		_legRight.on_deselected()
		
	if (Input.is_action_just_pressed("select_right_arm")):
		_armLeft.on_deselected()
		_armRight.on_selected()
		_legLeft.on_deselected()
		_legRight.on_deselected()
		
	if (Input.is_action_just_pressed("select_left_leg")):
		_armLeft.on_deselected()
		_armRight.on_deselected()
		_legLeft.on_selected()
		_legRight.on_deselected()
		
	if (Input.is_action_just_pressed("select_right_leg")):
		_armLeft.on_deselected()
		_armRight.on_deselected()
		_legLeft.on_deselected()
		_legRight.on_selected()
	
	_selectedLimb = null
	if _armLeft._selected:
		_selectedLimb = _armLeft
	if _armRight._selected:
		_selectedLimb = _armRight
	if _legLeft._selected:
		_selectedLimb = _legLeft
	if _legRight._selected:
		_selectedLimb = _legRight
		
func _physics_process(delta):
	var headLookAt = Vector2(-sin(_head.rotation), cos(_head.rotation))
	var mouseDir = (get_global_mouse_position() - _head.position).normalized()
	
#	var invMouseDir = Vector2(mouseDir.y, -mouseDir.x)
#	var headTorque = 50.0
#	var dot = headLookAt.dot(invMouseDir)
#	if dot > 0.0:
#		_head.applied_torque = -headTorque * abs(dot)
#	else:
#		_head.applied_torque = headTorque * abs(dot)

	var mouseRot = atan2(mouseDir.x, mouseDir.y)
	_head.rotation = -mouseRot + PI
	
func get_average_grabber_pos():
	var pos = _armLeft.grabber_pos()
	pos += _armRight.grabber_pos()
	pos += _legLeft.grabber_pos()
	pos += _legRight.grabber_pos()
	return pos / 4.0	

func get_camera_pos():
	if _selectedLimb != null:
		return _selectedLimb.grabber_pos()
	else:
		return get_average_grabber_pos()

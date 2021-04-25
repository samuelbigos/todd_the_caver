extends Node2D
class_name Player

var _limbs = []
var _selectedLimb = null
var _signs = []
var _lastSign = null
var _game = null
var _ftueLabel = null
var _ftueLabelPos
var _didGrab
var _FTUETimer = 0.0
var _grabbingDisabled = false
var _inCore = false
var _inCoreTimer = 0.0
var _tearTriggered = false
var _tearTimer = 0.0
var _torn = false
var _lastTorsoPos

enum FTUEState {
	E,
	D,
	A,
	Q,
	Grab,
	Move,
	R,
	None	
} 
var _ftueState = FTUEState.E

export var _hitSFX = []

onready var _handLeft = get_node("ArmLeft/HandLeft")
onready var _torso = get_node("Torso")
onready var _head = get_node("Head")

onready var _armLeft = get_node("ArmLeft")
onready var _armRight = get_node("ArmRight")
onready var _legLeft = get_node("LegLeft")
onready var _legRight = get_node("LegRight")

onready var _armLeftPin = get_node("Torso/LeftArmPin")
onready var _armRightPin = get_node("Torso/RightArmPin")
onready var _legLeftPin = get_node("Torso/LeftLegPin")
onready var _legRightPin = get_node("Torso/RightLegPin")

onready var _armLeftP = get_node("Torso/LeftArmP")
onready var _armRightP = get_node("Torso/RightArmP")
onready var _legLeftP = get_node("Torso/LeftLegP")
onready var _legRightP = get_node("Torso/RightLegP")

onready var _signLabel = get_node("../CanvasLayer/Label")

onready var _hitPlayer = get_node("HitPlayer")
onready var _checkpointPlayer = get_node("CheckpointPlayer")
onready var _bridgeCollapsePlayer = get_node("BridgeCollapsePlayer")
onready var _musicPlayer = get_node("MusicPlayer")

func _ready():
	_game = get_tree().get_nodes_in_group("game")[0]
	_ftueLabel = get_tree().get_nodes_in_group("ftue_label")[0]
	_ftueLabelPos = _ftueLabel.rect_position
	
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
			
	if _ftueState == FTUEState.E:
		_ftueLabel.text = "[E]"
		_torso.mode = RigidBody2D.MODE_STATIC
		_ftueLabel.visible = true
		
	_signs = get_tree().get_nodes_in_group("sign")
	#_lastSign = _signs[1]
	
	var triggers = get_tree().get_nodes_in_group("trigger")
	for trigger in triggers:
		trigger.connect("on_body_entered", self, "_on_trigger_entered")
		trigger.connect("on_body_exited", self, "_on_trigger_exited")
		
func _on_trigger_entered(body, trigger):
	if body == _torso:
		match trigger.triggerName:
			"bone_thrower":
				var boneSpawner = get_tree().get_nodes_in_group("bone_spawner")[0]
				boneSpawner._throwing = true

			"bridge_collapse":
				var ropeBridge = get_tree().get_nodes_in_group("rope_bridge_2")[0]
				ropeBridge.collapse(_torso.global_position)
				var boneSpawner = get_tree().get_nodes_in_group("bone_spawner")[0]
				boneSpawner._throwing = false
				_grabbingDisabled = true
				_bridgeCollapsePlayer.play()

			"enable_climb":
				_grabbingDisabled = false
				
			"core":
				_inCore = true
				
func _on_trigger_exited(body, trigger):
	if body == _torso:
		match trigger.triggerName:
			"core":
				_inCore = false
				_inCoreTimer = 0.0
				
func disableFTUE():
	_ftueState = FTUEState.None
	_torso.mode = RigidBody2D.MODE_RIGID
	_ftueLabel.visible = false
	
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
		
	# reset
	if Input.is_action_just_released("reset"):
		if _lastSign == null:
			_game.respawn_player(Vector2(0.0, 0.0))
		else:
			_game.respawn_player(_lastSign)
			
	_processFTUE()
	_FTUETimer += delta
	
	if _inCore:
		_inCoreTimer += delta
		if _inCoreTimer > 5.0 and not _tearTriggered:
			_beginTearApart()
	
	if not _torn:
		_lastTorsoPos = _torso.position
		
	if _tearTriggered and not _torn:
		_tearTimer += delta
		if _tearTimer > 4.0:
			_bridgeCollapsePlayer.play()
			_torn = true
			_armLeftPin.queue_free()
			_armRightPin.queue_free()
			_legLeftPin.queue_free()
			_legRightPin.queue_free()
			_armLeftP.emitting = true
			_armRightP.emitting = true
			_legLeftP.emitting = true
			_legRightP.emitting = true
			_game.end()
			
func _beginTearApart():
	_armLeft.overrideForce()
	_armRight.overrideForce()
	_legLeft.overrideForce()
	_legRight.overrideForce()
	_tearTriggered = true
	_torn = false
	_tearTimer = 0.0
			
func _processFTUE():
	match _ftueState:
		FTUEState.E:
			if Input.is_action_just_released("select_right_arm"):
				_ftueState = FTUEState.D
				_ftueLabel.text = "[D]"
				_FTUETimer = 0.0
		FTUEState.D:
			if Input.is_action_just_released("select_right_leg"):
				_ftueState = FTUEState.A
				_ftueLabel.text = "[A]"
				_FTUETimer = 0.0
		FTUEState.A:
			if Input.is_action_just_released("select_left_leg"):
				_ftueState = FTUEState.Q
				_ftueLabel.text = "[Q]"
				_FTUETimer = 0.0
		FTUEState.Q:
			if Input.is_action_just_released("select_left_arm"):
				_ftueState = FTUEState.Grab
				_ftueLabel.text = "HOLD [LeftMouse] - grab a surface"
				_FTUETimer = 0.0
		FTUEState.Grab:
			if Input.is_action_pressed("grab") and _didGrab:
				_torso.mode = RigidBody2D.MODE_RIGID
				_ftueState = FTUEState.Move
				_ftueLabel.text = "MOVE [Mouse] - move body"
				_FTUETimer = 0.0
		FTUEState.Move:
			if Input.is_action_just_released("grab") and _didGrab:
				_ftueState = FTUEState.R
				_ftueLabel.text = "[R] - reset to last checkpoint"
				_FTUETimer = 0.0
		FTUEState.R:
			if Input.is_action_just_released("reset"):
				_ftueState = FTUEState.None
				_ftueLabel.visible = false
				
	if _ftueLabel.visible:
		var time = _FTUETimer * 2.0
		_ftueLabel.rect_pivot_offset = _ftueLabel.rect_size / 2.0
		_ftueLabel.rect_scale = Vector2(1.25 + abs(sin(time)) * 0.5, 1.25 + abs(sin(time)) * 0.5)
		_ftueLabel.rect_rotation = (sin(time)) * 5.0
		
func _physics_process(delta):
	var headLookAt = Vector2(-sin(_head.rotation), cos(_head.rotation))
	var mouseDir = (get_global_mouse_position() - _head.global_position).normalized()
	
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
	if _torn:
		return _lastTorsoPos
	if _selectedLimb != null:
		return _selectedLimb.grabber_pos()
	else:
		return get_average_grabber_pos()

func set_checkpoint(theSign):
	if _lastSign != theSign or not _musicPlayer.playing:
		if theSign.music != null:
			_musicPlayer.stream = theSign.music
			_musicPlayer.play()
			
	if theSign.cutMusic:
		_musicPlayer.stop()
		
	if _lastSign != theSign:
		_checkpointPlayer.play()
		_lastSign = theSign	

func _on_body_entered(body):
	if not body.is_in_group("body"):
		_hitPlayer.stream = _hitSFX[randi() % _hitSFX.size()]
		_hitPlayer.play()

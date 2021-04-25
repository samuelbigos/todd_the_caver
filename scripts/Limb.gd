extends Node2D
class_name Limb

export var mouseForce = 750.0
export var grabStrength = 7500.0
export var upperIndex = 0
export var lowerIndex = 1
export var grabberIndex = 2
export var defaultCol := Color.white

var _selected := false
var _grabbing := false
var _grabBeginPos : Vector2
var _grabLastPos : Vector2
var _grabDelta : Vector2
var _resetForces := false
var _touchingWalls = 0

var _player = null
var _grabber : RigidBody2D = null
var _lower : RigidBody2D = null
var _upper : RigidBody2D = null
var _torso : RigidBody2D = null

var _elements = []
var _sprites = []

func _ready():
	for body in get_children():
		if body.get_class() == "RigidBody2D":
			_elements.append(body)
			body.add_to_group("body")
			for sprite in body.get_children():
				if sprite.get_class() == "Sprite":
					_sprites.append(sprite)
					
	_grabber = _elements[grabberIndex]
	_lower = _elements[lowerIndex]
	_upper = _elements[upperIndex]	
	
	_grabber.contact_monitor = true
	_grabber.contacts_reported = 10
	_grabber.connect("body_entered", self, "_on_body_entered")
	_grabber.connect("body_exited", self, "_on_body_exited")
					
func on_selected():
	_selected = true
		
func on_deselected():
	_selected = false
	_grabber.mode = RigidBody.MODE_RIGID
	_resetForces = true
	_grabbing = false	

func _physics_process(delta):
	if _selected:
		var mousePos = get_global_mouse_position()
		var toMouse = (mousePos - _grabber.global_position).normalized()
		_grabber.applied_force = toMouse * mouseForce
		_lower.applied_force = toMouse * mouseForce * 0.5
		_upper.applied_force = _grabDelta * 0.5
		_torso.applied_force = _grabDelta * 0.5
	elif _resetForces:
		_grabber.applied_force = Vector2(0.0, 0.0)
		_lower.applied_force = Vector2(0.0, 0.0)
		_upper.applied_force = Vector2(0.0, 0.0)
		_torso.applied_force = Vector2(0.0, 0.0)
		_resetForces = false
	
func _process(delta):
	if _torso == null:
		_torso = get_tree().get_nodes_in_group("torso")[0]
	if _player == null:
		_player = get_tree().get_nodes_in_group("player")[0]
		
	if _selected:
		if Input.is_action_pressed("grab") and _can_grab() and not _grabbing:
			_grabBeginPos = get_viewport().get_mouse_position()
			_grabLastPos = _grabBeginPos
			_grabber.mode = RigidBody.MODE_STATIC
			_grabbing = true
			_player._didGrab = true
			
		if _grabbing:
			var mousePos = get_global_mouse_position()
			var grabPosDelta = (_grabLastPos - mousePos).normalized()
			_grabLastPos = mousePos
			_grabDelta = grabStrength * grabPosDelta
			#_grabDelta = -(mousePos - _grabber.position) * grabStrength * 0.1
		
		if (Input.is_action_just_released("grab") or _player._grabbingDisabled) and _grabbing:
			_grabDelta = Vector2(0.0, 0.0)
			_grabber.mode = RigidBody.MODE_RIGID
			_grabbing = false
		
	_set_colour(defaultCol)
	if _selected:
		_set_colour(Color("d93e3e"))
	if _selected and _can_grab():
		_sprites[grabberIndex].modulate = Color("4584ff")
			
func _set_colour(var color):
	for sprite in _sprites:
		sprite.modulate = color

func _can_grab():
	return _touchingWalls > 0 and _player._grabbingDisabled == false
	
func grabber_pos():
	return _grabber.position
	
func _on_body_entered(var other):
	if not other.is_in_group("body"):
		_touchingWalls += 1

func _on_body_exited(var other):
	if not other.is_in_group("body"):
		_touchingWalls -= 1

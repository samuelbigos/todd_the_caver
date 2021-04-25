extends Node2D

export var segmentScene : PackedScene
export var supportDist = 100.0

onready var _start = get_node("Start")
onready var _end = get_node("End")

export var segmentLength = 10.0

var _ropeStatics = []
var _ropeSupportedSegments = []
var _ropeSprites = []

var _segments = []

func _ready():	
	var startPos = _start.position
	var endPos = _end.position
	var length = (endPos - startPos).length()
	
	var startStatic = StaticBody2D.new()
	startStatic.position = startPos
	add_child(startStatic)
	
	var endStatic = StaticBody2D.new()
	endStatic.position =endPos
	add_child(endStatic)
	
	var nextSupport = supportDist
	var current = 0.0
	var prev = null
	while current < length:
		var segment = segmentScene.instance()
		segment.position = startPos + (endPos - startPos).normalized() * (current + segmentLength * 0.5)
		add_child(segment)
		if prev == null:
			segment.set_connected(startStatic)
		else:
			segment.set_connected(prev)
		prev = segment
		current += segmentLength
		
		if current > nextSupport:
			nextSupport = nextSupport + supportDist
			
			var ropeStatic = StaticBody2D.new()
			ropeStatic.position = segment.position - Vector2(0.0, 200.0)
			add_child(ropeStatic)
			
			var supportPin = PinJoint2D.new()
			supportPin.position = segment.position
			supportPin.set_softness(0.5)
			supportPin.bias = 0.5
			add_child(supportPin)
			supportPin.set_node_a(ropeStatic.get_path())
			supportPin.set_node_b(segment.get_path())
			
			var ropeSprite = Sprite.new()
			ropeSprite.texture = load("res://assets/1px.png")
			add_child(ropeSprite)
			
			_ropeStatics.append(ropeStatic)
			_ropeSupportedSegments.append(segment)
			_ropeSprites.append(ropeSprite)
			
		_segments.append(segment)
		
	var endPin = PinJoint2D.new()
	endPin.set_softness(0.5)
	endPin.bias = 0.5
	add_child(endPin)
	endPin.set_node_a(endStatic.get_path())
	endPin.set_node_b(prev.get_path())
	
func collapse(pos):
	var closest = null
	var dist = 99999.9
	for segment in _segments:
		var length = (segment.global_position - pos).length()
		if (length < dist):
			dist = length
			closest = segment

	closest.break_joint()
	
func _process(delta):
	for i in range(0, _ropeStatics.size()):
		var sprite = _ropeSprites[i]
		sprite.position = (_ropeSupportedSegments[i].position + _ropeStatics[i].position) * 0.5
		sprite.scale = Vector2(1.0, (_ropeSupportedSegments[i].position - _ropeStatics[i].position).length())
		var rotVec = (_ropeSupportedSegments[i].position - _ropeStatics[i].position).normalized()
		sprite.rotation = atan2(rotVec.x, rotVec.y)

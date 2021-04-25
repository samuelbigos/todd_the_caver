extends Node2D

export var _boneScenes = []
export var _throwTimeRange = Vector2(0.5, 3.0)
export var _throwSpeed = 10.0
export var _throwTorque = 10.0

var _throwTimer = 0.0
var _throwing = false

func _process(delta):
	if _throwing:
		_throwTimer -= delta
		if _throwTimer < 0.0:
			_throwTimer = rand_range(_throwTimeRange.x, _throwTimeRange.y)
			
			var bone : RigidBody2D
			var i = randi() % 3
			if i == 0:
				bone = _boneScenes[0].instance()
			else:
				bone = _boneScenes[1].instance()
				
			add_child(bone)
			bone.global_position = global_position
			var impulse = ($ThrowDir.global_position - global_position) * _throwSpeed
			impulse *= rand_range(0.8, 1.2)
			bone.apply_impulse(Vector2(0.0, 0.0), impulse)
			bone.applied_torque = rand_range(-_throwTorque, _throwTorque)

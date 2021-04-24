extends Node2D

onready var _camera = get_node("MainCamera")
onready var _player = get_node("Player")

export var camSpeed = 10.0

var _cameraPos = Vector2(0.0, 0.0)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	_cameraPos = _player.get_camera_pos() + _player.position
	
func _process(delta):
	var desiredPos = _player.get_camera_pos() + _player.position
	_cameraPos = _cameraPos + (desiredPos - _cameraPos) * delta * camSpeed
	#_camera.position.x = int(_cameraPos.x)
	#_camera.position.y = int(_cameraPos.y)
	_camera.position = _cameraPos

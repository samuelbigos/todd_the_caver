extends Node2D

onready var _camera = get_node("MainCamera")
onready var _spawnPos = get_node("PlayerSpawner")

export var playerScene : PackedScene
export var camSpeed = 10.0

var _player
var _cameraPos = Vector2(0.0, 0.0)

func _ready():
	var spawnLoc = _spawnPos.position
	_player = playerScene.instance()
	_player.position = spawnLoc
	add_child(_player)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	_cameraPos = _player.get_camera_pos() + _player.position
	
func _process(delta):
	var desiredPos = _player.get_camera_pos() + _player.position
	_cameraPos = _cameraPos + (desiredPos - _cameraPos) * delta * camSpeed
	#_camera.position.x = int(_cameraPos.x)
	#_camera.position.y = int(_cameraPos.y)
	_camera.position = _cameraPos

func respawn_player(lastSign):
	_player.queue_free()
	_player = playerScene.instance()
	if is_instance_valid(lastSign):
		_player.position = lastSign.global_position + Vector2(0.0, -15.0)
		add_child(_player)
		_player._lastSign = lastSign
	else:
		_player.queue_free()
		_player = playerScene.instance()
		_player.position = Vector2(0.0, 0.0)
		add_child(_player)
	_player.disableFTUE()

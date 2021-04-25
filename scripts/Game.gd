extends Node2D

onready var _camera = get_node("MainCamera")
onready var _spawnPos = get_node("PlayerSpawner")

onready var _endControl = get_node("CanvasLayer/Control")
onready var _winLabel = get_node("CanvasLayer/Control/WinLabel")
onready var _timeLabel = get_node("CanvasLayer/Control/TimeLabel")
onready var _creditsLabel = get_node("CanvasLayer/Control/CreditsLabel")
onready var _windowSizeLabel = get_node("CanvasLayer/ToggleWindowSize")

export var playerScene : PackedScene
export var camSpeed = 10.0

enum WindowScale {
	Medium,
	Large,
	Full
}

var _player
var _cameraPos = Vector2(0.0, 0.0)
var _gameStart = 0.0
var _ended = false
var _windowScale = WindowScale.Large
var _toggleWindowSizeTimer = 0.0

func _ready():
	var spawnLoc = _spawnPos.position
	_player = playerScene.instance()
	_player.position = spawnLoc
	add_child(_player)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	_cameraPos = _player.get_camera_pos() + _player.position
	
	_gameStart = OS.get_system_time_msecs()
	
func _process(delta):
	var desiredPos = _player.get_camera_pos() + _player.position
	_cameraPos = _cameraPos + (desiredPos - _cameraPos) * delta * camSpeed
	#_camera.position.x = int(_cameraPos.x)
	#_camera.position.y = int(_cameraPos.y)
	_camera.position = _cameraPos
	
	_toggleWindowSizeTimer += delta
	if _toggleWindowSizeTimer > 5.0:
		_windowSizeLabel.visible = false
	else:
		var time = OS.get_system_time_msecs() / 500.0 + PI * 0.5
		_windowSizeLabel.rect_pivot_offset = _windowSizeLabel.rect_size / 2.0
		_windowSizeLabel.rect_scale = Vector2(1.25 + abs(sin(time)) * 0.1, 1.25 + abs(sin(time)) * 0.1)
		_windowSizeLabel.rect_rotation = (sin(time)) * 1.0
	
	_ended = true
	if _ended:
		var time = OS.get_system_time_msecs() / 500.0
		
		_winLabel.rect_pivot_offset = _winLabel.rect_size / 2.0
		_winLabel.rect_scale = Vector2(1.25 + abs(sin(time)) * 0.5, 1.25 + abs(sin(time)) * 0.5)
		_winLabel.rect_rotation = (sin(time)) * 5.0
		
		time += PI * 0.5
		_timeLabel.rect_pivot_offset = _timeLabel.rect_size / 2.0
		_timeLabel.rect_scale = Vector2(1.5 + abs(sin(time)) * 0.75, 1.25 + abs(sin(time)) * 0.75)
		_timeLabel.rect_rotation = (sin(time)) * 5.0
			
		time += PI * 0.5
		_creditsLabel.rect_pivot_offset = _creditsLabel.rect_size / 2.0
		_creditsLabel.rect_scale = Vector2(1.1 + abs(sin(time)) * 0.1, 1.1 + abs(sin(time)) * 0.1)
		_creditsLabel.rect_rotation = (sin(time)) * 1.0
		
	if Input.is_action_just_released("fullscreen"):
		match _windowScale:
			WindowScale.Medium:
				_windowScale = WindowScale.Large
				OS.set_window_size(Vector2(1280, 720))
			WindowScale.Large:
				_windowScale = WindowScale.Full
				OS.window_fullscreen = true
			WindowScale.Full:
				_windowScale = WindowScale.Medium
				OS.window_fullscreen = false
				OS.set_window_size(Vector2(640, 360))

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

func end():
	_ended = true
	_endControl.visible = true
	var finishTime = int(OS.get_system_time_msecs() - _gameStart)
	var ms = finishTime % 1000
	var seconds = int(finishTime / 1000.0) % 60
	var minutes = int(finishTime / 1000.0 / 60.0)
	_timeLabel.text = String(minutes) + "m " + String(seconds) + "." + String(ms / 10) + "s"

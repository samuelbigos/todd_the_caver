extends Area2D

export var triggerName = ""

signal on_body_entered(body, trigger)
signal on_body_exited(body, trigger)

func _init():
	add_to_group("trigger")
	
func _ready():
	connect("body_entered", self, "on_body_entered")
	connect("body_exited", self, "on_body_exited")
	
func on_body_entered(body):
	emit_signal("on_body_entered", body, self)

func on_body_exited(body):
	emit_signal("on_body_exited", body, self)

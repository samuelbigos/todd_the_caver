extends Area2D

export var triggerName = ""

signal on_body_entered(body, trigger)

func _init():
	add_to_group("trigger")
	
func _ready():
	connect("body_entered", self, "on_body_entered")
	
func on_body_entered(body):
	emit_signal("on_body_entered", body, self)

extends Node3D
class_name Door

@export var start_open: bool = false
var is_open: bool = false

func _ready():
	if start_open == true:
		$AnimationPlayer.play("door_open")
		is_open = true
	else:
		$AnimationPlayer.play("door_close")
		is_open = false

func toggle_door():
	if is_open:
		$AnimationPlayer.play("door_close")
		is_open = false
	else:
		$AnimationPlayer.play("door_open")
		is_open = true


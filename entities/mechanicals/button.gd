extends Node3D

@export var door1_path: NodePath
var door1: Door
var is_pressed: bool = false

func _ready():
	door1 = get_node(door1_path)
	
	$ld53_mechanics/ButtonStatic/ButtonDetection.body_entered.connect(on_button_pressed)
	$ld53_mechanics/ButtonStatic/ButtonDetection.body_exited.connect(on_button_released)


func on_button_pressed(body: Node3D):
	print(body.name, " is triggering button")
	if is_pressed == true:
		# already pressed, do nothing
		return

	is_pressed = true
	if door1.has_method("toggle_door"):
		door1.toggle_door()
	else:
		print("Failed to toggle door on press")

func on_button_released(_body: Node3D):
	if is_pressed == false:
		# already not pressed, do nothing
		return
	
	var existing_bodies: Array = $ld53_mechanics/ButtonStatic/ButtonDetection.get_overlapping_bodies()
	if existing_bodies.size() == 0:
		is_pressed = false
		
	if is_pressed == false:
		if door1.has_method("toggle_door"):
			door1.toggle_door()
		else:
			print("Failed to toggle door on button release")
		

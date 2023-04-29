extends Control
class_name RobotControlInfo

const ROBOT_ENUMS = preload("res://robot_enums.gd")

func set_robot_name(robot_name: String):
	$VBoxContainer/RobotName.text = robot_name

func set_robot_state(state: ROBOT_ENUMS.ROBOT_STATE):
	$VBoxContainer/RobotState.text = "Currently " + ROBOT_ENUMS.ROBOT_STATE.keys()[state]


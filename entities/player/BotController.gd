extends Node
class_name BotController

const ROBOT_ENUMS = preload("res://robot_enums.gd")

@export var how_to_info_path: NodePath
@export var robot_control_path: NodePath
var how_to_info: Control
var robot_control: RobotControlInfo

var current_robot: RobotFollower

func _ready():
	how_to_info = get_node(how_to_info_path)
	robot_control = get_node(robot_control_path)

func select_robot(bot: RobotFollower):
	how_to_info.visible = false
	robot_control.visible = true
	
	if current_robot != null:
		current_robot.disconnect("robot_state_changed", on_robot_state_changed)
	
	current_robot = bot
	current_robot.robot_state_changed.connect(on_robot_state_changed)
	
	robot_control.set_robot_name(bot.name)
	robot_control.set_robot_state(current_robot.current_state)
	
func move_to_location(spot: Vector3):
	if current_robot == null:
		return
	
	print("Commanding ", current_robot.name, " to move to: ", spot)
	current_robot.set_move_to_pos(spot)
	current_robot.current_state = ROBOT_ENUMS.ROBOT_STATE.MOVE_TO
	robot_control.set_robot_state(current_robot.current_state)

func follow_player():
	if current_robot == null:
		return
	
	current_robot.current_state = ROBOT_ENUMS.ROBOT_STATE.FOLLOW
	robot_control.set_robot_state(current_robot.current_state)

func on_robot_state_changed(state: ROBOT_ENUMS.ROBOT_STATE):
	robot_control.set_robot_state(state)

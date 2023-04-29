extends Node

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
	
	current_robot = bot
	robot_control.set_robot_name(bot.name)
	
func move_to_location(spot: Vector3):
	#current_robot.set_new_target(spot)
	pass

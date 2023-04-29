extends RigidBody3D
class_name RobotFollower

const ROBOT_ENUMS = preload("res://robot_enums.gd")

signal robot_state_changed

const ROBOT_SPEED: float = 1000.0
const ANGULAR_VELOCITY: float = 5.0
const UPWARDS_ANGULAR_FACTOR : float = 4.0
const FOLLOW_STOP_DISTANCE : float = 5.0
const MOVE_TO_STOP_DISTANCE : float = 1.0

@export var player: Node3D
var move_target_pos: Vector3


var current_state : ROBOT_ENUMS.ROBOT_STATE

func _ready():
	current_state = ROBOT_ENUMS.ROBOT_STATE.FOLLOW

func _physics_process(delta):
	stay_upwards(delta)
	
	match(current_state):
		ROBOT_ENUMS.ROBOT_STATE.FOLLOW:
			# Face the player
			rotate_to_pos(player.global_position, delta)
			# Find distance to player
			var distance_to_target: float = global_position.distance_to(player.global_position)
			if distance_to_target < FOLLOW_STOP_DISTANCE:
				return
			# Move to player
			var direction_to_target: Vector3 = global_position.direction_to(player.global_position)
			apply_central_force(direction_to_target * ROBOT_SPEED * delta)
		ROBOT_ENUMS.ROBOT_STATE.STAY:
			return
		ROBOT_ENUMS.ROBOT_STATE.MOVE_TO:
			rotate_to_pos(move_target_pos, delta)
			# Find distance to move_target_pos
			var distance_to_target: float = global_position.distance_to(move_target_pos)
			if distance_to_target < MOVE_TO_STOP_DISTANCE:
				set_robot_command(ROBOT_ENUMS.ROBOT_STATE.STAY)
				return
			# Move to move_target_pos
			var direction_to_target: Vector3 = global_position.direction_to(move_target_pos)
			apply_central_force(direction_to_target * ROBOT_SPEED * delta)
	
func set_move_to_pos(pos: Vector3):
	move_target_pos = pos
	
func set_robot_command(cmd: ROBOT_ENUMS.ROBOT_STATE):
	current_state = cmd
	emit_signal("robot_state_changed", current_state)
	

func rotate_to_pos(face_to_pos: Vector3, delta: float):
	# Rotate so helicopter is facing the face_target
	var current_direction := -global_transform.basis.z
	var target_direction := (face_to_pos - global_transform.origin).normalized()
	# Get the axis to rotate on
	var axis := current_direction.cross(target_direction).normalized()
	# Make sure its not zero
	if axis == Vector3.ZERO:
		return
	var angle := current_direction.signed_angle_to(target_direction, axis)
	var angle_step: float = min(ANGULAR_VELOCITY * delta, abs(angle)) * sign(angle)
	rotate(axis, angle_step)

func stay_upwards(delta: float):
	# Rotate so robot is pointing upwards
	var current_upwards_direction := global_transform.basis.y
	var rotate_up_axis := current_upwards_direction.cross(Vector3.UP).normalized()
	if rotate_up_axis == Vector3.ZERO:
		return
	var rotate_up_angle := current_upwards_direction.signed_angle_to(Vector3.UP, rotate_up_axis)
	var rotate_up_angle_step: float = min(ANGULAR_VELOCITY * UPWARDS_ANGULAR_FACTOR * delta, abs(rotate_up_angle)) * sign(rotate_up_angle)
	rotate(rotate_up_axis, rotate_up_angle_step)

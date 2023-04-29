extends RigidBody3D
class_name RobotFollower

var plunger_scene = preload("res://entities/robots/plunger.tscn")
var toast_scene = preload("res://entities/robots/toast.tscn")
const ROBOT_ENUMS = preload("res://robot_enums.gd")

signal robot_state_changed

const ROBOT_SPEED: float = 1000.0
const ANGULAR_VELOCITY: float = 5.0
const UPWARDS_ANGULAR_FACTOR : float = 4.0
const FOLLOW_STOP_DISTANCE : float = 5.0
const MOVE_TO_STOP_DISTANCE : float = 1.0

# Sticky specific
const GRAPPLE_TO_STOP_DISTANCE: float = 1.0 
const GRAPPLE_TO_SPEED: float = 3000.0 
var has_plunger_landed: bool = false
var has_plunger_shot: bool = false
var plunge_to_pos: Vector3 = Vector3.ZERO
var plunger: Plunger

# Shooty specific
const SHOOT_SPEED: float = 1000.0
var toast1: RigidBody3D
var shoot_at_pos: Vector3



@export var player: Node3D
var move_target_pos: Vector3
@onready var audio_stream: AudioStreamPlayer3D = $AudioStreamPlayer3D

var current_state : ROBOT_ENUMS.ROBOT_STATE

enum ROBOT_TYPE {
	STICKY,
	SHOOTY,
	SMELLY
}
@export var type: ROBOT_TYPE

func _ready():
	current_state = ROBOT_ENUMS.ROBOT_STATE.STAY

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
			return
		ROBOT_ENUMS.ROBOT_STATE.STAY:
			return
		ROBOT_ENUMS.ROBOT_STATE.SPECIAL:
			# dumb but code each specific special right here yep thats right
			match(type):
				ROBOT_TYPE.STICKY:
					if plunge_to_pos == Vector3.ZERO:
						return
					if !has_plunger_shot:
						plunger = plunger_scene.instantiate()
						get_parent().add_child(plunger)
						plunger.plunger_landed.connect(on_plunger_landed)
						plunger.global_position = global_position + Vector3.UP * 2
						plunger.destination_pos = plunge_to_pos
						has_plunger_shot = true
						return
					if !has_plunger_landed:
						return
					if global_position.distance_to(plunge_to_pos) < GRAPPLE_TO_STOP_DISTANCE:
						destroy_plunger()
						set_robot_command(ROBOT_ENUMS.ROBOT_STATE.STAY)
					var direction_to_plunger: Vector3 = global_position.direction_to(plunge_to_pos)
					apply_central_force(direction_to_plunger * GRAPPLE_TO_SPEED * delta)
					return
				ROBOT_TYPE.SHOOTY:
#					if shoot_at_pos == Vector3.ZERO:
#						return
#					if toast1 != null:
#						toast1.queue_free()
#					toast1 = toast_scene.instantiate()
#					get_parent().add_child(toast1)
#					toast1.global_position = $ToastSpawn1.global_position
#
#					var direction_to_target = toast1.global_position.direction_to(shoot_at_pos).normalized()
##					var current_direction := toast1.global_transform.basis.y
##					# Get the axis to rotate on
##					var axis := current_direction.cross(direction_to_target).normalized()
##					# Make sure its not zero
##					if axis == Vector3.ZERO:
##						return
##					var angle := current_direction.signed_angle_to(direction_to_target, axis)
##					rotate(axis, angle)
#
#					toast1.apply_impulse(direction_to_target * SHOOT_SPEED)
					return
				ROBOT_TYPE.SMELLY:
					return
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
			return
	
func set_move_to_pos(pos: Vector3):
	move_target_pos = pos
	
func set_plunge_to_pos(pos: Vector3):
	plunge_to_pos = pos
	
func set_shoot_to_pos(pos: Vector3):
	shoot_at_pos = pos

func set_robot_command(cmd: ROBOT_ENUMS.ROBOT_STATE):
	current_state = cmd
	update_audio()
	destroy_plunger()
	emit_signal("robot_state_changed", current_state)
	
func update_audio():
	if audio_stream == null:
		print("Missing stream player")
		return
	
	match(current_state):
		ROBOT_ENUMS.ROBOT_STATE.FOLLOW:
			audio_stream.stream = load("res://assets/soundfx/motor_moving.wav")
			audio_stream.play()

func on_plunger_landed(pos: Vector3):
	plunge_to_pos = pos
	has_plunger_landed = true

func destroy_plunger():
	if plunger == null:
		return
	#plunger.disconnect("plunger_landed", on_plunger_landed)
	has_plunger_landed = false
	has_plunger_shot = false
	plunger.queue_free()

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

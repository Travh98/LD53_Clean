extends RigidBody3D
class_name RobotFollower

@onready var detection_area: Area3D = $DetectionArea

@export var target: Node3D
const ROBOT_SPEED: float = 1000.0
const ANGULAR_VELOCITY: float = 5.0
const UPWARDS_ANGULAR_FACTOR : float = 4.0
const TARGET_STOP_DISTANCE : float = 5.0

func _ready():
	print("Initializing Robot Follower")
	detection_area.body_entered.connect(on_detection_body_entered)

func _physics_process(delta):
	stay_upwards(delta)
	
	if target == null:
		return

	rotate_to_target(target, delta)

	var distance_to_target: float = global_position.distance_to(target.global_position)
	if distance_to_target < TARGET_STOP_DISTANCE:
		return
	
	var direction_to_target: Vector3 = global_position.direction_to(target.global_position)
	apply_central_force(direction_to_target * ROBOT_SPEED * delta)
	

func set_new_target(node: Node3D):
	target = node

func on_detection_body_entered(body: Node3D):
	if body.name == self.name:
		return
		
	if target == null:
		print(self.name, " found target: ", body.name)
		target = body

func rotate_to_target(face_target: Node3D, delta: float):
	# Rotate so helicopter is facing the face_target
	var current_direction := -global_transform.basis.z
	var target_direction := (face_target.transform.origin - global_transform.origin).normalized()
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

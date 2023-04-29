extends CharacterBody3D
class_name Plunger

signal plunger_landed

const ANGULAR_VELOCITY: float = 5.0
const SPEED: float = 5.0
const STOP_DIST: float = 0.5
var destination_pos: Vector3 = Vector3.ZERO

var has_landed: bool = false

func _physics_process(delta):
	rotate_to_pos(destination_pos, delta)

	if global_position.distance_to(destination_pos) < STOP_DIST:
		velocity = Vector3.ZERO
		has_landed = true
		emit_signal("plunger_landed", global_position)
		return

	velocity = global_position.direction_to(destination_pos).normalized() * SPEED
	move_and_slide()

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

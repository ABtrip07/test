extends Camera3D

## Over-the-shoulder 3rd-person camera (right shoulder).
## The camera sits behind-and-right of the target and looks parallel to the
## target's forward. Because the camera is offset right, the character appears
## on the LEFT of the frame — classic Gears/RE4 OTS framing.

@export var target: Node3D
@export var distance: float = 5.2      # Close behind
@export var height: float = 3.4        # Around shoulder height
@export var shoulder_offset: float = 1.6 # Lateral offset to the right of target midline
@export var follow_smoothness: float = 12.0
@export var look_ahead: float = 12.0   # How far ahead the camera looks

func attach(t: Node3D) -> void:
	target = t
	if target:
		_snap_to_target()

func _get_basis_vectors() -> Array:
	var yaw: float = target.rotation.y
	var forward: Vector3 = Vector3(sin(yaw), 0.0, cos(yaw))
	var right: Vector3 = Vector3(cos(yaw), 0.0, -sin(yaw))
	return [forward, right]

func _desired_position() -> Vector3:
	var vecs: Array = _get_basis_vectors()
	var forward: Vector3 = vecs[0]
	var right: Vector3 = vecs[1]
	return target.global_position - forward * distance + right * shoulder_offset + Vector3(0, height, 0)

func _snap_to_target() -> void:
	if target == null:
		return
	global_position = _desired_position()
	_aim_parallel()

func _aim_parallel() -> void:
	# Look parallel to the target's forward direction so the character sits
	# on the LEFT of the frame (since camera is offset to the right).
	var vecs: Array = _get_basis_vectors()
	var forward: Vector3 = vecs[0]
	var right: Vector3 = vecs[1]
	# Aim point: camera position pushed forward along target forward, plus a
	# little rightward so we're not pointing at infinity straight ahead.
	var aim: Vector3 = global_position + forward * look_ahead + right * (shoulder_offset * 0.3)
	# Keep the look point at the character's head height
	aim.y = target.global_position.y + 1.5
	look_at(aim, Vector3.UP)

func _process(delta: float) -> void:
	if target == null:
		return
	var desired: Vector3 = _desired_position()
	global_position = global_position.lerp(desired, clampf(delta * follow_smoothness, 0.0, 1.0))
	_aim_parallel()

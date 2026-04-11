extends Camera3D

## High-angle god view camera. Static by default; optional slow orbit.

@export var center: Vector3 = Vector3(0.0, 0.0, 0.0)
@export var radius: float = 55.0
@export var camera_height: float = 42.0
@export var angle: float = PI / 4.0
@export var orbit_speed: float = 0.0
@export var fov_deg: float = 45.0

func _ready() -> void:
	fov = fov_deg
	near = 0.1
	far = 500.0
	current = true
	_update_position()

func _process(delta: float) -> void:
	if orbit_speed > 0.0:
		angle += orbit_speed * delta
		_update_position()

func _update_position() -> void:
	var x: float = center.x + cos(angle) * radius
	var z: float = center.z + sin(angle) * radius
	global_position = Vector3(x, camera_height, z)
	look_at(center, Vector3.UP)

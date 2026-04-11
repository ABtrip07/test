extends Node3D

## Parametric parabolic projectile — represents a troop being flung by a trebuchet.
## Lands at target, emits `impact` with world position, then queue_frees.

signal impact(world_pos: Vector3)

var _start: Vector3
var _end: Vector3
var _duration: float = 1.6
var _elapsed: float = 0.0
var _peak_height: float = 10.0
var _body: MeshInstance3D
var _trail_accum: float = 0.0
var _spin_axis: Vector3 = Vector3(1, 0.4, 0.2).normalized()

func launch(from: Vector3, to: Vector3, duration: float, peak_height: float) -> void:
	_start = from
	_end = to
	_duration = maxf(0.25, duration)
	_peak_height = peak_height
	global_position = _start
	_build_body()

func _build_body() -> void:
	_body = MeshInstance3D.new()
	var sph: SphereMesh = SphereMesh.new()
	sph.radius = 0.55
	sph.height = 1.1
	_body.mesh = sph
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.25, 0.20, 0.15)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	mat.metallic = 0.0
	mat.roughness = 0.95
	_body.material_override = mat
	add_child(_body)

func _process(delta: float) -> void:
	_elapsed += delta
	var t: float = clampf(_elapsed / _duration, 0.0, 1.0)
	var flat: Vector3 = _start.lerp(_end, t)
	var arc: float = 4.0 * _peak_height * t * (1.0 - t)
	global_position = Vector3(flat.x, flat.y + arc, flat.z)
	_body.rotate(_spin_axis, delta * 8.0)
	if t >= 1.0:
		impact.emit(_end)
		queue_free()

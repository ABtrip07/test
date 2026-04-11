extends Node3D

## Cartoon battle puff: a dust cloud + "POW!" label at an impact site.
## Expands, fades, and frees itself. Used to show a raid landing.

var _puff: MeshInstance3D
var _label: Label3D
var _life: float = 1.6
var _age: float = 0.0
var _mat: StandardMaterial3D

func setup(world_pos: Vector3, text: String = "POW!", tint: Color = Color(1, 0.9, 0.5)) -> void:
	global_position = world_pos
	_puff = MeshInstance3D.new()
	var sph: SphereMesh = SphereMesh.new()
	sph.radius = 1.2
	sph.height = 2.4
	_puff.mesh = sph
	_mat = StandardMaterial3D.new()
	_mat.albedo_color = Color(0.9, 0.85, 0.65, 0.9)
	_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_puff.material_override = _mat
	_puff.position = Vector3(0, 1.2, 0)
	add_child(_puff)

	_label = Label3D.new()
	_label.text = text
	_label.pixel_size = 0.05
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.no_depth_test = true
	_label.modulate = tint
	_label.outline_size = 6
	_label.outline_modulate = Color(0.1, 0.05, 0.0)
	_label.position = Vector3(0, 4.0, 0)
	add_child(_label)
	set_process(true)

func _process(delta: float) -> void:
	_age += delta
	var t: float = clampf(_age / _life, 0.0, 1.0)
	var s: float = 1.0 + t * 2.2
	_puff.scale = Vector3(s, s, s)
	_label.position = Vector3(0, 4.0 + t * 1.6, 0)
	var a: float = clampf(1.0 - t, 0.0, 1.0)
	_mat.albedo_color = Color(0.9, 0.85, 0.65, a * 0.9)
	_label.modulate = Color(_label.modulate.r, _label.modulate.g, _label.modulate.b, a)
	if t >= 1.0:
		queue_free()

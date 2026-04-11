extends Node3D

## Visual for a single villager: capsule body + name label + morale bar.
## Wanders within a radius of its assigned lot.

var villager_id: StringName
var clan_id: StringName
var home_pos: Vector3
var _wander_target: Vector3
var _move_speed: float = 1.8
var _wander_radius: float = 5.5
var _label: Label3D
var _morale_bar: MeshInstance3D
var _morale_mat: StandardMaterial3D
var _morale_refresh_accum: float = 0.0
var _panic_remaining: float = 0.0
var _panic_speed: float = 4.5
var _panic_dir: Vector3 = Vector3.ZERO

func setup(p_villager_id: StringName, p_clan_id: StringName, p_home_pos: Vector3) -> void:
	villager_id = p_villager_id
	clan_id = p_clan_id
	home_pos = p_home_pos
	global_position = _pick_wander_point()
	_wander_target = _pick_wander_point()
	_build_meshes()
	_refresh_label_and_morale()

func _build_meshes() -> void:
	var body: MeshInstance3D = MeshInstance3D.new()
	var cap: CapsuleMesh = CapsuleMesh.new()
	cap.radius = 0.5
	cap.height = 2.0
	body.mesh = cap
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = FactionPalette.primary_color(clan_id)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	mat.metallic = 0.1
	mat.roughness = 0.6
	body.material_override = mat
	body.position = Vector3(0, 1.0, 0)
	add_child(body)

	_label = Label3D.new()
	_label.pixel_size = 0.025
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.no_depth_test = false
	_label.modulate = Color(1, 0.96, 0.8)
	_label.outline_size = 3
	_label.outline_modulate = Color(0.1, 0.08, 0.05)
	_label.position = Vector3(0, 3.2, 0)
	add_child(_label)

	_morale_bar = MeshInstance3D.new()
	var bar_mesh: BoxMesh = BoxMesh.new()
	bar_mesh.size = Vector3(1.4, 0.15, 0.15)
	_morale_bar.mesh = bar_mesh
	_morale_mat = StandardMaterial3D.new()
	_morale_mat.albedo_color = Color(0.4, 1.0, 0.5)
	_morale_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_morale_bar.material_override = _morale_mat
	_morale_bar.position = Vector3(0, 2.7, 0)
	add_child(_morale_bar)

func _pick_wander_point() -> Vector3:
	var angle: float = randf() * TAU
	var dist: float = randf_range(1.0, _wander_radius)
	return home_pos + Vector3(cos(angle) * dist, 0.0, sin(angle) * dist)

func panic_flee(threat_pos: Vector3, seconds: float = 3.0) -> void:
	_panic_remaining = maxf(_panic_remaining, seconds)
	var away: Vector3 = global_position - threat_pos
	away.y = 0.0
	if away.length() < 0.01:
		away = Vector3(randf() * 2.0 - 1.0, 0.0, randf() * 2.0 - 1.0)
	_panic_dir = away.normalized()

func visual_tick(delta: float) -> void:
	if _panic_remaining > 0.0:
		_panic_remaining -= delta
		var step: Vector3 = _panic_dir * _panic_speed * delta
		global_position += step
		if _panic_remaining <= 0.0:
			_wander_target = _pick_wander_point()
	else:
		var to_target: Vector3 = _wander_target - global_position
		to_target.y = 0.0
		var dist: float = to_target.length()
		if dist < 0.3:
			_wander_target = _pick_wander_point()
		else:
			var step: Vector3 = to_target.normalized() * _move_speed * delta
			global_position += step
	_morale_refresh_accum += delta
	if _morale_refresh_accum >= 0.25:
		_morale_refresh_accum = 0.0
		_refresh_label_and_morale()

func _refresh_label_and_morale() -> void:
	var v: VillagerTypes.VillagerData = Villagers.get_villager(villager_id)
	if v == null:
		return
	_label.text = v.display_name
	var m_ratio: float = clampf(v.morale / 100.0, 0.0, 1.0)
	_morale_bar.scale = Vector3(maxf(0.05, m_ratio), 1.0, 1.0)
	# Shift color from red -> green based on morale
	_morale_mat.albedo_color = Color(1.0 - m_ratio, m_ratio, 0.3)

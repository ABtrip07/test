extends Node3D

## Simple melee troop unit — a small clan-colored capsule that runs toward its
## nearest enemy and hits them on contact. Lives for `max_life` seconds or until
## its HP hits zero, whichever comes first. The battle layer clears itself when
## one side is wiped out.

signal died(unit: Node3D)

var clan_id: StringName
var hp: float = 6.0
var dmg: float = 2.0
var move_speed: float = 3.4
var attack_range: float = 1.2
var attack_cooldown: float = 0.6
var _attack_timer: float = 0.0
var _body: MeshInstance3D
var _hp_bar: MeshInstance3D
var _hp_mat: StandardMaterial3D
var _max_hp: float

func setup(p_clan_id: StringName, spawn_pos: Vector3, p_hp: float = 6.0, p_dmg: float = 2.0) -> void:
	clan_id = p_clan_id
	hp = p_hp
	_max_hp = p_hp
	dmg = p_dmg
	global_position = spawn_pos
	_build_meshes()

func _build_meshes() -> void:
	_body = MeshInstance3D.new()
	var cap: CapsuleMesh = CapsuleMesh.new()
	cap.radius = 0.35
	cap.height = 1.3
	_body.mesh = cap
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = FactionPalette.primary_color(clan_id)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	mat.metallic = 0.1
	mat.roughness = 0.7
	_body.material_override = mat
	_body.position = Vector3(0, 0.7, 0)
	add_child(_body)

	_hp_bar = MeshInstance3D.new()
	var bar: BoxMesh = BoxMesh.new()
	bar.size = Vector3(1.0, 0.12, 0.12)
	_hp_bar.mesh = bar
	_hp_mat = StandardMaterial3D.new()
	_hp_mat.albedo_color = Color(0.4, 1.0, 0.5)
	_hp_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_hp_bar.material_override = _hp_mat
	_hp_bar.position = Vector3(0, 1.8, 0)
	add_child(_hp_bar)

func take_damage(amount: float) -> void:
	hp = maxf(0.0, hp - amount)
	var r: float = clampf(hp / _max_hp, 0.0, 1.0)
	_hp_bar.scale = Vector3(maxf(0.05, r), 1.0, 1.0)
	_hp_mat.albedo_color = Color(1.0 - r, r, 0.3)
	if hp <= 0.0:
		died.emit(self)
		queue_free()

func tick_combat(delta: float, enemies: Array) -> void:
	if enemies.is_empty():
		return
	# Find nearest enemy still alive
	var nearest: Node3D = null
	var nearest_dist: float = 1e9
	for e: Node3D in enemies:
		if e == null or not is_instance_valid(e):
			continue
		var d: float = global_position.distance_to(e.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = e
	if nearest == null:
		return
	# Turn toward enemy
	var to: Vector3 = nearest.global_position - global_position
	to.y = 0.0
	if to.length() > 0.01:
		rotation.y = atan2(to.x, to.z)
	if nearest_dist > attack_range:
		var step: Vector3 = to.normalized() * move_speed * delta
		global_position += step
	else:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_attack_timer = attack_cooldown
			if nearest.has_method("take_damage"):
				nearest.take_damage(dmg)

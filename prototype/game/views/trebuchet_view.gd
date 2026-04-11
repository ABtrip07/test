extends Node3D

## Fantasy trebuchet visual: wooden base + throwing arm that winds up and fires.
## Owned by a lot. Fires troop projectiles at enemy lots on raid decrees.

signal fire_ready(launch_world_pos: Vector3, direction: Vector3)

var clan_id: StringName
var _base: MeshInstance3D
var _arm: MeshInstance3D
var _arm_pivot: Node3D
var _counterweight: MeshInstance3D
var _wind_up_tween: Tween

func setup(p_clan_id: StringName) -> void:
	clan_id = p_clan_id
	_build_meshes()

func _build_meshes() -> void:
	var wood_col: Color = Color(0.45, 0.30, 0.18)
	var dark_wood: Color = Color(0.30, 0.20, 0.12)
	# Platform
	_base = _make_box(Vector3(3.0, 0.6, 3.0), wood_col)
	_base.position = Vector3(0, 0.3, 0)
	add_child(_base)
	# Two upright A-frame legs
	var leg_l: MeshInstance3D = _make_box(Vector3(0.35, 3.2, 0.35), dark_wood)
	leg_l.position = Vector3(-0.9, 1.8, 0)
	leg_l.rotation = Vector3(0, 0, deg_to_rad(10))
	add_child(leg_l)
	var leg_r: MeshInstance3D = _make_box(Vector3(0.35, 3.2, 0.35), dark_wood)
	leg_r.position = Vector3(0.9, 1.8, 0)
	leg_r.rotation = Vector3(0, 0, deg_to_rad(-10))
	add_child(leg_r)
	# Arm pivot so we can rotate the whole arm
	_arm_pivot = Node3D.new()
	_arm_pivot.position = Vector3(0, 3.0, 0)
	add_child(_arm_pivot)
	_arm = _make_box(Vector3(0.3, 4.5, 0.3), dark_wood)
	_arm.position = Vector3(0, -1.0, 0)
	_arm_pivot.add_child(_arm)
	_counterweight = _make_box(Vector3(0.9, 0.9, 0.9), Color(0.25, 0.20, 0.15))
	_counterweight.position = Vector3(0, 1.8, 0)
	_arm_pivot.add_child(_counterweight)
	# Banner
	var pole: MeshInstance3D = _make_box(Vector3(0.1, 2.4, 0.1), Color(0.2, 0.15, 0.1))
	pole.position = Vector3(1.3, 1.8, 1.3)
	add_child(pole)
	var flag: MeshInstance3D = _make_box(
		Vector3(1.0, 0.7, 0.05),
		FactionPalette.primary_color(clan_id)
	)
	flag.position = Vector3(1.9, 2.3, 1.3)
	add_child(flag)
	# Rest pose: arm tilted back (cocked)
	_arm_pivot.rotation = Vector3(deg_to_rad(-45), 0, 0)

func play_fire_animation(target_pos: Vector3) -> void:
	# Aim yaw toward target
	var to: Vector3 = target_pos - global_position
	to.y = 0
	if to.length() > 0.01:
		rotation.y = atan2(to.x, to.z)
	# Wind up then snap forward
	if _wind_up_tween:
		_wind_up_tween.kill()
	_wind_up_tween = create_tween()
	_wind_up_tween.tween_property(_arm_pivot, "rotation",
		Vector3(deg_to_rad(-75), 0, 0), 0.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_wind_up_tween.tween_property(_arm_pivot, "rotation",
		Vector3(deg_to_rad(70), 0, 0), 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_wind_up_tween.tween_callback(func(): _emit_fire_ready(target_pos))
	# Return to rest
	_wind_up_tween.tween_property(_arm_pivot, "rotation",
		Vector3(deg_to_rad(-45), 0, 0), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _emit_fire_ready(target_pos: Vector3) -> void:
	var launch_world: Vector3 = global_position + Vector3(0, 5.0, 0)
	var dir: Vector3 = (target_pos - launch_world).normalized()
	fire_ready.emit(launch_world, dir)

func _make_mat(col: Color) -> StandardMaterial3D:
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = col
	m.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	m.metallic = 0.02
	m.roughness = 0.9
	return m

func _make_box(size: Vector3, col: Color) -> MeshInstance3D:
	var mi: MeshInstance3D = MeshInstance3D.new()
	var b: BoxMesh = BoxMesh.new()
	b.size = size
	mi.mesh = b
	mi.material_override = _make_mat(col)
	return mi

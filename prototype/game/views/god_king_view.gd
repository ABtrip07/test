extends Node3D

## The God-King avatar — a 3rd-person controllable character who can drop into
## the battle mid-raid. Implements a For Honor-style 3-stance combat system:
## stance can be UP, DOWN-LEFT, DOWN-RIGHT. Attacking from one stance hits only
## if the defender's guard is in a different stance. Parry works on a matching
## stance within a short window.

enum Stance { UP, DOWN_LEFT, DOWN_RIGHT }

signal stance_changed(new_stance: int)
signal swing_thrown(from_stance: int)
signal hit_attempted(origin: Vector3, forward: Vector3, hit_range: float, arc_deg: float, dmg: float)
signal died()

const RUN_SPEED: float = 7.5
const TURN_SPEED: float = 8.0
const SWING_WINDUP: float = 0.25
const PARRY_WINDOW: float = 0.35
# Combat tuning — a bit stronger than a CoC hero. Tanky wrecking ball that
# can be overwhelmed by swarms but cleaves through mobs when uncontested.
const MAX_HP: float = 110.0
const SWING_DMG: float = 14.0
const SWING_RANGE: float = 3.0
const SWING_ARC_DEG: float = 110.0

var current_stance: int = Stance.UP
var clan_id: StringName = &"chosen"
var hp: float = MAX_HP
var max_hp: float = MAX_HP
var _body: MeshInstance3D
var _sword: MeshInstance3D
var _sword_pivot: Node3D
var _stance_indicator: Label3D
var _hp_bar: MeshInstance3D
var _hp_mat: StandardMaterial3D
var _facing_deg: float = 0.0
var _is_swinging: bool = false
var _swing_tween: Tween
var _parry_timer: float = 0.0
var _dead: bool = false
var _hit_flash_timer: float = 0.0
var _body_base_col: Color

func setup(spawn_pos: Vector3) -> void:
	global_position = spawn_pos
	hp = MAX_HP
	_dead = false
	_build_meshes()
	_set_stance(Stance.UP)

func _build_meshes() -> void:
	# Chibi proportions: stubby body, huge spherical head, tiny legs.
	var body_col: Color = FactionPalette.primary_color(FactionPalette.CHOSEN)
	_body_base_col = body_col
	var skin_col: Color = Color(0.96, 0.82, 0.68)
	var leg_col: Color = Color(0.42, 0.3, 0.18)
	# Stubby barrel torso
	_body = MeshInstance3D.new()
	var torso: SphereMesh = SphereMesh.new()
	torso.radius = 0.75
	torso.height = 1.2
	_body.mesh = torso
	_body.material_override = _mat(body_col, 0.2, 0.55)
	_body.position = Vector3(0, 0.9, 0)
	add_child(_body)
	# Golden belt
	var belt: MeshInstance3D = MeshInstance3D.new()
	var belt_cyl: CylinderMesh = CylinderMesh.new()
	belt_cyl.top_radius = 0.76
	belt_cyl.bottom_radius = 0.76
	belt_cyl.height = 0.18
	belt.mesh = belt_cyl
	belt.material_override = _mat(Color(0.95, 0.78, 0.25), 0.85, 0.25)
	belt.position = Vector3(0, 0.68, 0)
	add_child(belt)
	# Tiny stubby legs
	var leg_l: MeshInstance3D = _make_stub(Color(0.42, 0.3, 0.18), 0.25, 0.5)
	leg_l.position = Vector3(-0.28, 0.25, 0)
	add_child(leg_l)
	var leg_r: MeshInstance3D = _make_stub(Color(0.42, 0.3, 0.18), 0.25, 0.5)
	leg_r.position = Vector3(0.28, 0.25, 0)
	add_child(leg_r)
	# Huge spherical head
	var head: MeshInstance3D = MeshInstance3D.new()
	var head_sph: SphereMesh = SphereMesh.new()
	head_sph.radius = 0.95
	head_sph.height = 1.9
	head.mesh = head_sph
	head.material_override = _mat(skin_col, 0.0, 0.7)
	head.position = Vector3(0, 2.35, 0)
	add_child(head)
	# Two tiny eye dots so he has a face
	var eye_l: MeshInstance3D = _make_eye()
	eye_l.position = Vector3(-0.35, 2.45, 0.82)
	add_child(eye_l)
	var eye_r: MeshInstance3D = _make_eye()
	eye_r.position = Vector3(0.35, 2.45, 0.82)
	add_child(eye_r)
	# Oversized crown sitting on the big head
	var crown: MeshInstance3D = MeshInstance3D.new()
	var crown_cyl: CylinderMesh = CylinderMesh.new()
	crown_cyl.top_radius = 0.88
	crown_cyl.bottom_radius = 0.90
	crown_cyl.height = 0.55
	crown.mesh = crown_cyl
	crown.material_override = _mat(Color(1.0, 0.82, 0.2), 0.9, 0.2)
	crown.position = Vector3(0, 3.35, 0)
	add_child(crown)
	# Three crown spikes (simple cones)
	for i: int in range(5):
		var spike: MeshInstance3D = MeshInstance3D.new()
		var cone: CylinderMesh = CylinderMesh.new()
		cone.top_radius = 0.0
		cone.bottom_radius = 0.14
		cone.height = 0.5
		spike.mesh = cone
		spike.material_override = _mat(Color(1.0, 0.88, 0.25), 0.9, 0.2)
		var ang: float = float(i) / 5.0 * TAU
		spike.position = Vector3(cos(ang) * 0.78, 3.75, sin(ang) * 0.78)
		add_child(spike)
	# Arms: short stubs at the sides
	var arm_l: MeshInstance3D = _make_stub(body_col.darkened(0.1), 0.22, 0.7)
	arm_l.position = Vector3(-0.85, 1.2, 0)
	add_child(arm_l)
	# Sword pivot in the right hand
	_sword_pivot = Node3D.new()
	_sword_pivot.position = Vector3(0.85, 1.2, 0.1)
	add_child(_sword_pivot)
	var arm_r: MeshInstance3D = _make_stub(body_col.darkened(0.1), 0.22, 0.7)
	arm_r.position = Vector3(0, -0.2, 0)
	_sword_pivot.add_child(arm_r)
	_sword = MeshInstance3D.new()
	var blade: BoxMesh = BoxMesh.new()
	blade.size = Vector3(0.22, 2.4, 0.12)
	_sword.mesh = blade
	_sword.material_override = _mat(Color(0.90, 0.92, 0.96), 0.95, 0.15)
	_sword.position = Vector3(0, 1.0, 0)
	_sword_pivot.add_child(_sword)
	var guard: MeshInstance3D = MeshInstance3D.new()
	var gb: BoxMesh = BoxMesh.new()
	gb.size = Vector3(0.6, 0.1, 0.2)
	guard.mesh = gb
	guard.material_override = _mat(Color(0.95, 0.78, 0.2), 0.9, 0.2)
	guard.position = Vector3(0, 0.1, 0)
	_sword_pivot.add_child(guard)
	# Stance indicator floats above the crown
	_stance_indicator = Label3D.new()
	_stance_indicator.pixel_size = 0.06
	_stance_indicator.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_stance_indicator.no_depth_test = true
	_stance_indicator.modulate = Color(1, 0.95, 0.5)
	_stance_indicator.outline_size = 5
	_stance_indicator.outline_modulate = Color(0.1, 0.05, 0.0)
	_stance_indicator.position = Vector3(0, 4.5, 0)
	add_child(_stance_indicator)
	# Oversized HP bar above the crown — readable at chase-cam distance
	_hp_bar = MeshInstance3D.new()
	var bar: BoxMesh = BoxMesh.new()
	bar.size = Vector3(2.4, 0.24, 0.22)
	_hp_bar.mesh = bar
	_hp_mat = StandardMaterial3D.new()
	_hp_mat.albedo_color = Color(0.4, 1.0, 0.5)
	_hp_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_hp_bar.material_override = _hp_mat
	_hp_bar.position = Vector3(0, 5.05, 0)
	add_child(_hp_bar)

func _mat(col: Color, metallic: float, roughness: float) -> StandardMaterial3D:
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = col
	m.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	m.metallic = metallic
	m.roughness = roughness
	return m

func _make_stub(col: Color, radius: float, height: float) -> MeshInstance3D:
	var mi: MeshInstance3D = MeshInstance3D.new()
	var cyl: CylinderMesh = CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = height
	mi.mesh = cyl
	mi.material_override = _mat(col, 0.05, 0.7)
	return mi

func _make_eye() -> MeshInstance3D:
	var mi: MeshInstance3D = MeshInstance3D.new()
	var sph: SphereMesh = SphereMesh.new()
	sph.radius = 0.12
	sph.height = 0.24
	mi.mesh = sph
	mi.material_override = _mat(Color(0.08, 0.08, 0.10), 0.0, 0.8)
	return mi

func _set_stance(new_stance: int) -> void:
	current_stance = new_stance
	match current_stance:
		Stance.UP:
			_stance_indicator.text = "^"
			_sword_pivot.rotation = Vector3(0, 0, 0)
		Stance.DOWN_LEFT:
			_stance_indicator.text = "<"
			_sword_pivot.rotation = Vector3(0, 0, deg_to_rad(55))
		Stance.DOWN_RIGHT:
			_stance_indicator.text = ">"
			_sword_pivot.rotation = Vector3(0, 0, deg_to_rad(-55))
	stance_changed.emit(current_stance)

func set_stance_by_input(up: bool, left: bool, right: bool) -> void:
	if up:
		_set_stance(Stance.UP)
	elif left:
		_set_stance(Stance.DOWN_LEFT)
	elif right:
		_set_stance(Stance.DOWN_RIGHT)

func process_movement(delta: float, move_vec: Vector3) -> void:
	if _is_swinging or _dead:
		return
	if move_vec.length() > 0.05:
		var desired: Vector3 = move_vec.normalized() * RUN_SPEED * delta
		global_position += desired
		_facing_deg = lerp_angle(_facing_deg, atan2(desired.x, desired.z), TURN_SPEED * delta)
		rotation.y = _facing_deg

func swing() -> bool:
	if _is_swinging or _dead:
		return false
	_is_swinging = true
	var from: int = current_stance
	swing_thrown.emit(from)
	var start_rot: Vector3 = _sword_pivot.rotation
	var mid_rot: Vector3 = start_rot + Vector3(deg_to_rad(-90), 0, 0)
	_swing_tween = create_tween()
	_swing_tween.tween_property(_sword_pivot, "rotation", mid_rot, SWING_WINDUP) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# At the apex of the swing — blade extended — resolve hits.
	_swing_tween.tween_callback(func(): _emit_hit_attempt())
	_swing_tween.tween_property(_sword_pivot, "rotation", start_rot, 0.25) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_swing_tween.tween_callback(func(): _is_swinging = false)
	return true

func _emit_hit_attempt() -> void:
	if _dead:
		return
	var forward: Vector3 = Vector3(sin(_facing_deg), 0.0, cos(_facing_deg))
	# Origin at torso height — the sword sweeps roughly here.
	var origin: Vector3 = global_position + Vector3(0, 1.2, 0)
	hit_attempted.emit(origin, forward, SWING_RANGE, SWING_ARC_DEG, SWING_DMG)

func take_damage(amount: float) -> void:
	if _dead:
		return
	hp = maxf(0.0, hp - amount)
	var r: float = clampf(hp / max_hp, 0.0, 1.0)
	_hp_bar.scale = Vector3(maxf(0.05, r), 1.0, 1.0)
	_hp_mat.albedo_color = Color(1.0 - r, r, 0.3)
	_hit_flash_timer = 0.12
	if _body and _body.material_override:
		(_body.material_override as StandardMaterial3D).albedo_color = Color(1.0, 0.6, 0.5)
	if hp <= 0.0:
		_dead = true
		died.emit()

func start_parry() -> void:
	_parry_timer = PARRY_WINDOW

func is_parrying() -> bool:
	return _parry_timer > 0.0

## Resolve an incoming swing. Returns a string: "parry" | "block" | "hit"
func receive_incoming_swing(from_stance: int) -> String:
	if is_parrying() and from_stance == current_stance:
		return "parry"
	if from_stance == current_stance:
		return "block"
	return "hit"

func visual_tick(delta: float) -> void:
	if _parry_timer > 0.0:
		_parry_timer = maxf(0.0, _parry_timer - delta)
	if _hit_flash_timer > 0.0:
		_hit_flash_timer = maxf(0.0, _hit_flash_timer - delta)
		if _hit_flash_timer == 0.0 and _body and _body.material_override:
			(_body.material_override as StandardMaterial3D).albedo_color = _body_base_col

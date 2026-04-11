extends Node3D

## Procedural building visual — cartoon fantasy shapes.
## Picks mesh(es) based on (building_type, clan_id) and pops in with a scale tween.

var building_id: StringName
var building_type: int
var clan_id: StringName

func setup(p_id: StringName, p_type: int, p_clan_id: StringName) -> void:
	building_id = p_id
	building_type = p_type
	clan_id = p_clan_id
	_build_meshes()
	_popin_tween()

func _popin_tween() -> void:
	scale = Vector3(0.1, 0.1, 0.1)
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ONE, 0.9) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _build_meshes() -> void:
	match building_type:
		BuildingTypes.BuildingType.FARM:
			_build_farm()
		BuildingTypes.BuildingType.SCRAP_YARD:
			_build_quarry()
		BuildingTypes.BuildingType.BARRACKS:
			_build_barracks()
		BuildingTypes.BuildingType.SHRINE:
			_build_shrine()
		BuildingTypes.BuildingType.DATA_CORE:
			_build_wizard_tower()
		_:
			_fallback()

# ---------- Building shapes (clan-tinted) ----------

func _build_farm() -> void:
	# Thatched cottage: wood walls + conical thatch roof + chimney
	var wall_col: Color = _wall_color()
	var roof_col: Color = _roof_color()
	var walls: MeshInstance3D = _make_box(Vector3(4.5, 2.0, 4.5), wall_col)
	walls.position = Vector3(0, 1.0, 0)
	add_child(walls)
	var roof: MeshInstance3D = _make_cone(3.6, 2.4, roof_col)
	roof.position = Vector3(0, 3.2, 0)
	add_child(roof)
	var chimney: MeshInstance3D = _make_cylinder(0.35, 0.35, 1.6, Color(0.45, 0.38, 0.32))
	chimney.position = Vector3(1.3, 3.6, 1.3)
	add_child(chimney)
	_add_banner(Vector3(-2.4, 2.0, 2.4))
	_add_label("Farmstead")

func _build_quarry() -> void:
	# Stone quarry tower: rough stone cylinder, capped pile of rocks, pickaxe
	var base: MeshInstance3D = _make_cylinder(1.6, 2.2, 3.2, Color(0.55, 0.52, 0.48))
	base.position = Vector3(0, 1.6, 0)
	add_child(base)
	var rim: MeshInstance3D = _make_cylinder(2.0, 2.0, 0.4, Color(0.38, 0.36, 0.32))
	rim.position = Vector3(0, 3.3, 0)
	add_child(rim)
	var pile1: MeshInstance3D = _make_sphere(0.9, Color(0.48, 0.45, 0.42))
	pile1.position = Vector3(2.4, 0.7, 0.4)
	add_child(pile1)
	var pile2: MeshInstance3D = _make_sphere(0.7, Color(0.55, 0.50, 0.45))
	pile2.position = Vector3(-2.0, 0.55, 1.8)
	add_child(pile2)
	_add_banner(Vector3(1.8, 2.0, -1.8))
	_add_label("Quarry")

func _build_barracks() -> void:
	# Fortified longhouse: thick walls + peaked roof + two flanking towers + big banner
	var primary: Color = FactionPalette.primary_color(clan_id)
	var walls: MeshInstance3D = _make_box(Vector3(6.5, 2.6, 4.2), _wall_color())
	walls.position = Vector3(0, 1.3, 0)
	add_child(walls)
	var roof: MeshInstance3D = _make_box(Vector3(6.8, 0.6, 4.6), _roof_color())
	roof.position = Vector3(0, 2.9, 0)
	add_child(roof)
	var tower_l: MeshInstance3D = _make_cylinder(0.9, 1.0, 4.2, Color(0.62, 0.58, 0.52))
	tower_l.position = Vector3(-3.0, 2.1, 0)
	add_child(tower_l)
	var tower_r: MeshInstance3D = _make_cylinder(0.9, 1.0, 4.2, Color(0.62, 0.58, 0.52))
	tower_r.position = Vector3(3.0, 2.1, 0)
	add_child(tower_r)
	var crown_l: MeshInstance3D = _make_cone(1.1, 1.2, primary)
	crown_l.position = Vector3(-3.0, 4.8, 0)
	add_child(crown_l)
	var crown_r: MeshInstance3D = _make_cone(1.1, 1.2, primary)
	crown_r.position = Vector3(3.0, 4.8, 0)
	add_child(crown_r)
	_add_banner(Vector3(0, 2.6, 2.2), 1.6)
	_add_label("Barracks")

func _build_shrine() -> void:
	# Stone obelisk with glowing orb on a stepped base
	var step1: MeshInstance3D = _make_box(Vector3(4.0, 0.5, 4.0), Color(0.60, 0.58, 0.52))
	step1.position = Vector3(0, 0.25, 0)
	add_child(step1)
	var step2: MeshInstance3D = _make_box(Vector3(3.0, 0.4, 3.0), Color(0.70, 0.66, 0.58))
	step2.position = Vector3(0, 0.7, 0)
	add_child(step2)
	var pillar: MeshInstance3D = _make_cylinder(0.6, 0.8, 3.5, Color(0.78, 0.74, 0.62))
	pillar.position = Vector3(0, 2.65, 0)
	add_child(pillar)
	var orb: MeshInstance3D = _make_glowing_sphere(0.7, FactionPalette.accent_color(clan_id))
	orb.position = Vector3(0, 4.8, 0)
	add_child(orb)
	_add_label("Shrine")

func _build_wizard_tower() -> void:
	# Tall round stone tower with a conical witch-hat roof + flag
	var base: MeshInstance3D = _make_cylinder(1.5, 1.8, 5.2, Color(0.66, 0.62, 0.55))
	base.position = Vector3(0, 2.6, 0)
	add_child(base)
	var band: MeshInstance3D = _make_cylinder(1.55, 1.55, 0.35, FactionPalette.primary_color(clan_id))
	band.position = Vector3(0, 4.6, 0)
	add_child(band)
	var hat: MeshInstance3D = _make_cone(1.9, 2.6, _roof_color())
	hat.position = Vector3(0, 6.6, 0)
	add_child(hat)
	var flag_pole: MeshInstance3D = _make_cylinder(0.07, 0.07, 1.4, Color(0.25, 0.2, 0.15))
	flag_pole.position = Vector3(0, 8.6, 0)
	add_child(flag_pole)
	_add_banner(Vector3(0.5, 8.5, 0), 0.8)
	_add_label("Arcane Tower")

# ---------- Fallback ----------

func _fallback() -> void:
	var body: MeshInstance3D = _make_box(Vector3(3, 2, 3), Color(0.55, 0.55, 0.58))
	body.position = Vector3(0, 1.0, 0)
	add_child(body)
	_add_label("???")

# ---------- Clan-tinted material palette helpers ----------

func _wall_color() -> Color:
	match clan_id:
		FactionPalette.CHOSEN: return Color(0.82, 0.70, 0.52)    # warm timber
		FactionPalette.RIVAL: return Color(0.42, 0.30, 0.22)     # dark charred wood
		FactionPalette.NEUTRAL: return Color(0.75, 0.66, 0.50)   # sunbleached timber
	return Color(0.7, 0.65, 0.5)

func _roof_color() -> Color:
	match clan_id:
		FactionPalette.CHOSEN: return Color(0.78, 0.55, 0.25)    # golden thatch
		FactionPalette.RIVAL: return Color(0.30, 0.20, 0.16)     # dark slate
		FactionPalette.NEUTRAL: return Color(0.68, 0.50, 0.28)   # straw
	return Color(0.6, 0.45, 0.25)

# ---------- Mesh + banner helpers ----------

func _make_mat(col: Color) -> StandardMaterial3D:
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = col
	m.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	m.metallic = 0.05
	m.roughness = 0.85
	return m

func _make_glow_mat(col: Color) -> StandardMaterial3D:
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = col
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.emission_enabled = true
	m.emission = col
	m.emission_energy_multiplier = 1.6
	return m

func _make_box(size: Vector3, col: Color) -> MeshInstance3D:
	var mi: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mi.mesh = box
	mi.material_override = _make_mat(col)
	return mi

func _make_sphere(radius: float, col: Color) -> MeshInstance3D:
	var mi: MeshInstance3D = MeshInstance3D.new()
	var sph: SphereMesh = SphereMesh.new()
	sph.radius = radius
	sph.height = radius * 2.0
	mi.mesh = sph
	mi.material_override = _make_mat(col)
	return mi

func _make_glowing_sphere(radius: float, col: Color) -> MeshInstance3D:
	var mi: MeshInstance3D = MeshInstance3D.new()
	var sph: SphereMesh = SphereMesh.new()
	sph.radius = radius
	sph.height = radius * 2.0
	mi.mesh = sph
	mi.material_override = _make_glow_mat(col)
	return mi

func _make_cylinder(top_r: float, bot_r: float, h: float, col: Color) -> MeshInstance3D:
	var mi: MeshInstance3D = MeshInstance3D.new()
	var cyl: CylinderMesh = CylinderMesh.new()
	cyl.top_radius = top_r
	cyl.bottom_radius = bot_r
	cyl.height = h
	mi.mesh = cyl
	mi.material_override = _make_mat(col)
	return mi

func _make_cone(base_r: float, h: float, col: Color) -> MeshInstance3D:
	# CylinderMesh with top_radius=0 => cone.
	return _make_cylinder(0.0, base_r, h, col)

func _add_banner(pos: Vector3, scale_mult: float = 1.0) -> void:
	var pole: MeshInstance3D = _make_cylinder(0.08, 0.08, 2.4 * scale_mult, Color(0.25, 0.2, 0.15))
	pole.position = pos
	add_child(pole)
	var flag: MeshInstance3D = _make_box(
		Vector3(1.2 * scale_mult, 0.8 * scale_mult, 0.05),
		FactionPalette.primary_color(clan_id)
	)
	flag.position = pos + Vector3(0.7 * scale_mult, 0.7 * scale_mult, 0.0)
	add_child(flag)
	var trim: MeshInstance3D = _make_box(
		Vector3(1.2 * scale_mult, 0.15 * scale_mult, 0.06),
		FactionPalette.accent_color(clan_id)
	)
	trim.position = pos + Vector3(0.7 * scale_mult, 1.05 * scale_mult, 0.0)
	add_child(trim)

func _add_label(text: String) -> void:
	var lbl: Label3D = Label3D.new()
	lbl.text = text
	lbl.pixel_size = 0.028
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lbl.no_depth_test = true
	lbl.modulate = Color(1, 0.98, 0.9)
	lbl.outline_size = 4
	lbl.outline_modulate = Color(0.1, 0.08, 0.05)
	lbl.position = Vector3(0, 6.0, 0)
	add_child(lbl)

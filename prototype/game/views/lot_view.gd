extends Node3D

## Visual for a single lot: colored ground pad + owner ring + label.

var lot_id: StringName
var owning_clan_id: StringName

var _ground_material: StandardMaterial3D
var _ring_material: StandardMaterial3D
var _label: Label3D
var _buildings_container: Node3D

func setup(p_lot_id: StringName, p_world_pos: Vector3, p_clan_id: StringName) -> void:
	lot_id = p_lot_id
	owning_clan_id = p_clan_id
	global_position = p_world_pos
	_build_meshes()
	_apply_clan_color()

func _build_meshes() -> void:
	# Ground quad
	var ground: MeshInstance3D = MeshInstance3D.new()
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(LotLayout.LOT_SIZE, LotLayout.LOT_SIZE)
	ground.mesh = plane
	_ground_material = StandardMaterial3D.new()
	_ground_material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	_ground_material.metallic = 0.05
	_ground_material.roughness = 0.85
	ground.material_override = _ground_material
	ground.position = Vector3(0, 0.01, 0)
	add_child(ground)

	# Owner ring (flat torus on ground)
	var ring: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = LotLayout.LOT_SIZE * 0.45
	torus.outer_radius = LotLayout.LOT_SIZE * 0.50
	ring.mesh = torus
	_ring_material = StandardMaterial3D.new()
	_ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_ring_material.emission_enabled = true
	_ring_material.emission_energy_multiplier = 1.0
	ring.material_override = _ring_material
	ring.position = Vector3(0, 0.05, 0)
	add_child(ring)

	# Container for buildings placed on this lot
	_buildings_container = Node3D.new()
	_buildings_container.name = "Buildings"
	add_child(_buildings_container)

	# Label above lot
	_label = Label3D.new()
	_label.pixel_size = 0.04
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.no_depth_test = false
	_label.modulate = Color(1, 0.96, 0.85)
	_label.outline_size = 5
	_label.outline_modulate = Color(0.1, 0.08, 0.05)
	_label.position = Vector3(0, 5.0, 0)
	add_child(_label)
	_refresh_label()

func recolor_for_clan(new_clan_id: StringName) -> void:
	owning_clan_id = new_clan_id
	_apply_clan_color()
	_refresh_label()

func _apply_clan_color() -> void:
	_ground_material.albedo_color = FactionPalette.ground_color(owning_clan_id)
	var ring_col: Color = FactionPalette.ring_color(owning_clan_id)
	_ring_material.albedo_color = ring_col
	_ring_material.emission = ring_col

func _refresh_label() -> void:
	_label.text = "%s\n[%s]" % [String(lot_id), FactionPalette.clan_display_name(owning_clan_id)]

func get_spawn_point() -> Vector3:
	return global_position + Vector3(randf_range(-2.0, 2.0), 0.0, randf_range(-2.0, 2.0))

func add_building_view(bv: Node3D) -> void:
	_buildings_container.add_child(bv)

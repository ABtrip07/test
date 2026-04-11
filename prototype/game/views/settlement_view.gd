extends Node3D

## Root 3D view container. Holds all lot views, cannons, projectiles, and puffs.
## Driven by GameController — it pushes state here.

const LotViewScript := preload("res://game/views/lot_view.gd")
const BuildingViewScript := preload("res://game/views/building_view.gd")
const VillagerViewScript := preload("res://game/views/villager_view.gd")
const TrebuchetViewScript := preload("res://game/views/trebuchet_view.gd")
const ProjectileViewScript := preload("res://game/views/projectile_view.gd")
const BattlePuffScript := preload("res://game/views/battle_puff_view.gd")
const BattleUnitScript := preload("res://game/views/battle_unit_view.gd")

signal battle_resolved(lot_id: StringName, winning_clan: StringName)

var _lot_views: Dictionary = {}  # StringName lot_id -> Node3D (lot_view)
var _villager_views: Dictionary = {}  # StringName villager_id -> Node3D (villager_view)
var _building_views: Dictionary = {}  # StringName building_id -> Node3D (building_view)
var _trebuchets: Dictionary = {}  # StringName lot_id -> Node3D (trebuchet_view)
var _active_battles: Dictionary = {}  # StringName lot_id -> { attackers: [], defenders: [], attacker_clan, defender_clan, timer }

@onready var _lots_container: Node3D = Node3D.new()
@onready var _cannons_container: Node3D = Node3D.new()
@onready var _projectiles_container: Node3D = Node3D.new()
@onready var _battles_container: Node3D = Node3D.new()

func _ready() -> void:
	_lots_container.name = "LotViews"
	_cannons_container.name = "Cannons"
	_projectiles_container.name = "ProjectileLayer"
	_battles_container.name = "BattleLayer"
	add_child(_lots_container)
	add_child(_cannons_container)
	add_child(_projectiles_container)
	add_child(_battles_container)

func spawn_lot(lot_data: LotTypes.LotData) -> void:
	var lv: Node3D = Node3D.new()
	lv.set_script(LotViewScript)
	lv.name = "Lot_%s" % String(lot_data.lot_id)
	_lots_container.add_child(lv)
	lv.setup(lot_data.lot_id, LotLayout.to_world_3d(lot_data.world_position), lot_data.owning_clan_id)
	_lot_views[lot_data.lot_id] = lv

func get_lot_view(lot_id: StringName) -> Node3D:
	return _lot_views.get(lot_id, null)

func recolor_lot(lot_id: StringName, new_clan_id: StringName) -> void:
	var lv: Node3D = _lot_views.get(lot_id, null)
	if lv:
		lv.recolor_for_clan(new_clan_id)

func spawn_villager(villager_id: StringName, clan_id: StringName, home_lot_id: StringName) -> void:
	var lv: Node3D = _lot_views.get(home_lot_id, null)
	if lv == null:
		return
	var vv: Node3D = Node3D.new()
	vv.set_script(VillagerViewScript)
	vv.name = "Villager_%s" % String(villager_id)
	add_child(vv)  # parented directly to SettlementView so wandering is in world space
	vv.setup(villager_id, clan_id, lv.global_position)
	_villager_views[villager_id] = vv

func spawn_building(building: BuildingTypes.BuildingData, clan_id: StringName) -> void:
	var lv: Node3D = _lot_views.get(building.lot_id, null)
	if lv == null:
		return
	var bv: Node3D = Node3D.new()
	bv.set_script(BuildingViewScript)
	bv.name = "Building_%s" % String(building.building_id)
	lv.add_building_view(bv)
	bv.setup(building.building_id, building.building_type, clan_id)
	_building_views[building.building_id] = bv

func spawn_trebuchet(lot_id: StringName, clan_id: StringName) -> void:
	var lv: Node3D = _lot_views.get(lot_id, null)
	if lv == null or _trebuchets.has(lot_id):
		return
	var tv: Node3D = Node3D.new()
	tv.set_script(TrebuchetViewScript)
	tv.name = "Trebuchet_%s" % String(lot_id)
	_cannons_container.add_child(tv)
	# Place the trebuchet at the lot edge facing inward (simple offset)
	tv.global_position = lv.global_position + Vector3(4.5, 0, -4.5)
	tv.setup(clan_id)
	_trebuchets[lot_id] = tv

func get_trebuchet(lot_id: StringName) -> Node3D:
	return _trebuchets.get(lot_id, null)

func launch_projectile(from: Vector3, to: Vector3, duration: float = 1.6, peak_height: float = 10.0) -> Node3D:
	var pj: Node3D = Node3D.new()
	pj.set_script(ProjectileViewScript)
	_projectiles_container.add_child(pj)
	pj.launch(from, to, duration, peak_height)
	return pj

func start_live_battle(lot_id: StringName, attacker_clan: StringName, defender_clan: StringName, attacker_count: int, defender_count: int) -> void:
	var lv: Node3D = _lot_views.get(lot_id, null)
	if lv == null:
		return
	var center: Vector3 = lv.global_position
	var attackers: Array = []
	var defenders: Array = []
	for i: int in range(attacker_count):
		var u: Node3D = Node3D.new()
		u.set_script(BattleUnitScript)
		_battles_container.add_child(u)
		var ang: float = float(i) / float(maxi(1, attacker_count)) * TAU
		var spawn: Vector3 = center + Vector3(cos(ang) * 6.5, 0.0, sin(ang) * 6.5)
		u.setup(attacker_clan, spawn, 7.0, 2.2)
		attackers.append(u)
	for i: int in range(defender_count):
		var u2: Node3D = Node3D.new()
		u2.set_script(BattleUnitScript)
		_battles_container.add_child(u2)
		var ang2: float = float(i) / float(maxi(1, defender_count)) * TAU
		var spawn2: Vector3 = center + Vector3(cos(ang2) * 1.8, 0.0, sin(ang2) * 1.8)
		u2.setup(defender_clan, spawn2, 6.0, 1.8)
		defenders.append(u2)
	_active_battles[lot_id] = {
		"attackers": attackers,
		"defenders": defenders,
		"attacker_clan": attacker_clan,
		"defender_clan": defender_clan,
		"timer": 8.0,
	}

func has_active_battle(lot_id: StringName) -> bool:
	return _active_battles.has(lot_id)

func get_active_battle_center(lot_id: StringName) -> Vector3:
	var lv: Node3D = _lot_views.get(lot_id, null)
	return lv.global_position if lv else Vector3.ZERO

func get_any_active_battle_lot() -> StringName:
	for lid: StringName in _active_battles.keys():
		return lid
	return &""

func _tick_battles(delta: float) -> void:
	var to_resolve: Array = []
	for lot_id: StringName in _active_battles.keys():
		var b: Dictionary = _active_battles[lot_id]
		b.attackers = (b.attackers as Array).filter(func(u): return is_instance_valid(u))
		b.defenders = (b.defenders as Array).filter(func(u): return is_instance_valid(u))
		for a: Node3D in b.attackers:
			a.tick_combat(delta, b.defenders)
		for d: Node3D in b.defenders:
			d.tick_combat(delta, b.attackers)
		b.timer -= delta
		if b.attackers.is_empty() or b.defenders.is_empty() or b.timer <= 0.0:
			to_resolve.append(lot_id)
	for lot_id: StringName in to_resolve:
		_resolve_battle(lot_id)

func _resolve_battle(lot_id: StringName) -> void:
	var b: Dictionary = _active_battles[lot_id]
	var attacker_alive: int = (b.attackers as Array).size()
	var defender_alive: int = (b.defenders as Array).size()
	var winner: StringName = b.attacker_clan if attacker_alive > defender_alive else b.defender_clan
	# Clean up any surviving units
	for u: Node3D in b.attackers:
		if is_instance_valid(u):
			u.queue_free()
	for u2: Node3D in b.defenders:
		if is_instance_valid(u2):
			u2.queue_free()
	_active_battles.erase(lot_id)
	battle_resolved.emit(lot_id, winner)

func spawn_battle_puff(world_pos: Vector3, text: String = "POW!", tint: Color = Color(1, 0.9, 0.5)) -> void:
	var bp: Node3D = Node3D.new()
	bp.set_script(BattlePuffScript)
	_battles_container.add_child(bp)
	bp.setup(world_pos, text, tint)

func alert_villagers_at_lot(lot_id: StringName, panic_seconds: float = 3.0) -> void:
	var lv: Node3D = _lot_views.get(lot_id, null)
	if lv == null:
		return
	var lot_pos: Vector3 = lv.global_position
	for vv: Node3D in _villager_views.values():
		if not vv.has_method("panic_flee"):
			continue
		var dx: Vector3 = vv.global_position - lot_pos
		dx.y = 0.0
		if dx.length() < 8.0:
			vv.panic_flee(lot_pos, panic_seconds)

func visual_tick(delta: float) -> void:
	# Per-frame pump for villagers, projectiles, puffs, cannons.
	for vv: Node3D in _villager_views.values():
		if vv.has_method("visual_tick"):
			vv.visual_tick(delta)
	for c in _cannons_container.get_children():
		if c.has_method("visual_tick"):
			c.visual_tick(delta)
	for p in _projectiles_container.get_children():
		if p.has_method("visual_tick"):
			p.visual_tick(delta)
	_tick_battles(delta)

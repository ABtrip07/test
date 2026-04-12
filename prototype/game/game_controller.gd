extends Node

## The single brain of the MVP game. Ticks the simulation and routes signals
## between autoloads and views / HUD.

const PLAYER_CLAN := &"chosen"
const RIVAL_CLAN := &"rival_salvagers"
const NEUTRAL_CLAN := &"neutral_wasters"

const TICK_INTERVAL: float = 0.5
const RIVAL_CANNON_INTERVAL: float = 18.0
const DEBUG_AUTO_RAID_AT: float = 0.0  # seconds — 0.0 to disable demo raid
const DEBUG_AUTO_GODKING_AT: float = 0.0  # seconds — 0.0 to disable demo drop-in

var _economy: EconomyTicker
var _rival_civ: RivalCivilization
var _lieutenants: Array[LieutenantAI] = []
var _lieutenant_names: Dictionary = {}
var _lot_squads: Dictionary = {}
var _tick_accum: float = 0.0
var _rival_cannon_accum: float = 0.0
var _game_tick_count: int = 0
var _debug_auto_raid_accum: float = 0.0
var _debug_auto_raid_fired: bool = false
var _debug_auto_godking_accum: float = 0.0
var _debug_auto_godking_fired: bool = false
var _auto_build_counter: int = 0
var _auto_squad_counter: int = 0
var _need_warn_cooldowns: Dictionary = {}  # (vid, need) -> cooldown remaining
var _pending_attack_lots: Dictionary = {}  # target_lot_id -> true while in flight
var _raid_target_index: int = 0  # round-robin pointer for player raid target

@onready var _settlement: Node3D = $World/Settlement
@onready var _hud: CanvasLayer = $HUDRoot
@onready var _orbit_camera: Camera3D = $World/OrbitCamera

const GodKingViewScript := preload("res://game/views/god_king_view.gd")
const ChaseCameraScript := preload("res://game/views/chase_camera.gd")

var _god_king: Node3D
var _chase_camera: Camera3D
var _god_king_mode: bool = false

func _ready() -> void:
	randomize()
	_reset_all_subsystems()
	_economy = EconomyTicker.new()
	var seed_info: Dictionary = WorldSeed.seed_world(_economy)
	_lieutenants = seed_info["lieutenants"] as Array[LieutenantAI]
	_lieutenant_names = WorldSeed.lieutenant_display_names()
	_lot_squads = WorldSeed.lot_squads_map()
	_rival_civ = RivalCivilization.new(&"quantist_hegemony", "Quantist Hegemony", 10.0)

	_build_settlement_views()
	_spawn_trebuchets()
	_initialize_hud()
	_connect_autoload_signals()

	_push_event("The Sigil stirs. Food 200, Scrap 80, Fuel 20.", Color(0.8, 0.9, 1.0))

func _reset_all_subsystems() -> void:
	Resources.reset()
	Villagers.reset()
	Decrees.reset()
	Lots.reset()
	Army.reset()
	Clans.reset()

func _spawn_trebuchets() -> void:
	# Player gets a trebuchet at home_base. Rival gets one at each of their lots.
	_settlement.spawn_trebuchet(&"home_base", PLAYER_CLAN)
	for lot: LotTypes.LotData in Lots.get_lots_by_clan(RIVAL_CLAN):
		_settlement.spawn_trebuchet(lot.lot_id, RIVAL_CLAN)

func _build_settlement_views() -> void:
	for lot: LotTypes.LotData in Lots.get_all_lots():
		_settlement.spawn_lot(lot)
	for building: BuildingTypes.BuildingData in _economy.get_all_buildings():
		var lot_data: LotTypes.LotData = Lots.get_lot_data(building.lot_id)
		var clan_id: StringName = lot_data.owning_clan_id if lot_data else NEUTRAL_CLAN
		_settlement.spawn_building(building, clan_id)
	for vid: StringName in Villagers.get_all_villager_ids():
		var v: VillagerTypes.VillagerData = Villagers.get_villager(vid)
		if v == null:
			continue
		_settlement.spawn_villager(v.villager_id, v.clan_id, v.assigned_lot_id)

func _initialize_hud() -> void:
	if _hud and _hud.has_method("initialize"):
		_hud.initialize(self)

func _connect_autoload_signals() -> void:
	Decrees.decree_issued.connect(_on_decree_issued)
	Decrees.decree_completed.connect(_on_decree_completed)
	Villagers.villager_need_critical.connect(_on_villager_need_critical)
	Lots.lot_ownership_changed.connect(_on_lot_ownership_changed)
	if _settlement.has_signal("battle_resolved"):
		_settlement.battle_resolved.connect(_on_battle_resolved)

func _process(delta: float) -> void:
	_tick_accum += delta
	while _tick_accum >= TICK_INTERVAL:
		_tick_accum -= TICK_INTERVAL
		_game_tick(TICK_INTERVAL)
	if _settlement and _settlement.has_method("visual_tick"):
		_settlement.visual_tick(delta)
	if _god_king_mode and _god_king:
		_process_god_king_input(delta)
		_god_king.visual_tick(delta)
	# Cooldown decay for need-critical throttling
	for key: Variant in _need_warn_cooldowns.keys():
		_need_warn_cooldowns[key] = maxf(0.0, _need_warn_cooldowns[key] - delta)
	# Debug auto-raid (demo)
	if DEBUG_AUTO_RAID_AT > 0.0 and not _debug_auto_raid_fired:
		_debug_auto_raid_accum += delta
		if _debug_auto_raid_accum >= DEBUG_AUTO_RAID_AT:
			_debug_auto_raid_fired = true
			trigger_raid_decree()
	# Debug auto-godking (demo)
	if DEBUG_AUTO_GODKING_AT > 0.0 and not _debug_auto_godking_fired:
		_debug_auto_godking_accum += delta
		if _debug_auto_godking_accum >= DEBUG_AUTO_GODKING_AT:
			_debug_auto_godking_fired = true
			_toggle_godking_mode()

func _game_tick(dt: float) -> void:
	_game_tick_count += 1
	Villagers.tick_villagers(dt)
	var report: Dictionary = _economy.tick_economy(dt, Resources, Villagers)
	if report.get("food_shortage", false):
		_push_event("FOOD SHORTAGE at the gates!", Color(1.0, 0.55, 0.3))
	Decrees.tick_decrees(dt)
	_rival_civ.tick_civilization(dt)

	_rival_cannon_accum += dt
	if _rival_cannon_accum >= RIVAL_CANNON_INTERVAL:
		_rival_cannon_accum = 0.0
		_fire_rival_raid()

func _fire_rival_raid() -> void:
	var rival_lots: Array = Lots.get_lots_by_clan(RIVAL_CLAN)
	var player_lots: Array = Lots.get_lots_by_clan(PLAYER_CLAN)
	if rival_lots.is_empty() or player_lots.is_empty():
		return
	var source_lot: LotTypes.LotData = rival_lots[randi() % rival_lots.size()]
	var target_lot: LotTypes.LotData = player_lots[randi() % player_lots.size()]
	if _pending_attack_lots.get(target_lot.lot_id, false):
		return
	_pending_attack_lots[target_lot.lot_id] = true
	if _hud and _hud.has_method("show_raid_banner"):
		_hud.show_raid_banner(
			"INCOMING RAID!",
			"The Quantists strike %s!" % String(target_lot.lot_id),
			Color(1.0, 0.3, 0.25)
		)
	_push_event("The Quantists launch a raid on %s!" % String(target_lot.lot_id), Color(1.0, 0.55, 0.4))
	_fire_raid_salvo(source_lot.lot_id, target_lot.lot_id, RIVAL_CLAN)

# ---------- Signal handlers ----------

func _on_decree_issued(decree: DecreeTypes.Decree) -> void:
	var lt_name: String = _lieutenant_names.get(decree.assigned_lieutenant_id, String(decree.assigned_lieutenant_id))
	var type_name: String = DecreeTypes.DecreeType.keys()[decree.type]
	_push_event("%s takes up %s on %s" % [lt_name, type_name, String(decree.target_id)], Color(0.8, 0.8, 0.85))

func _on_decree_completed(decree: DecreeTypes.Decree) -> void:
	match decree.type:
		DecreeTypes.DecreeType.GATHER:
			_handle_gather_complete(decree)
		DecreeTypes.DecreeType.BUILD:
			_handle_build_complete(decree)
		DecreeTypes.DecreeType.ATTACK:
			_handle_attack_complete(decree)
		DecreeTypes.DecreeType.RECRUIT:
			_handle_recruit_complete(decree)
		_:
			_push_event("Decree complete (no effect): %s" % DecreeTypes.DecreeType.keys()[decree.type])

func _handle_gather_complete(_d: DecreeTypes.Decree) -> void:
	Resources.add_resource(ResourceTypes.ResourceType.SCRAP, 25.0)
	_push_event("Gather complete: +25 Scrap.", Color(0.6, 1.0, 0.7))

func _handle_build_complete(_d: DecreeTypes.Decree) -> void:
	_push_event("Build decree complete (hookup pending).", Color(0.8, 0.9, 1.0))

func _handle_attack_complete(d: DecreeTypes.Decree) -> void:
	# AI-issued attack decree from a lieutenant (not the player-triggered raid).
	# Fire a salvo from the best friendly trebuchet lot toward the target.
	var target_id: StringName = d.target_id
	if _pending_attack_lots.get(target_id, false):
		return  # already in flight from player click
	var target_lot: LotTypes.LotData = Lots.get_lot_data(target_id)
	if target_lot == null:
		return
	_pending_attack_lots[target_id] = true
	_fire_raid_salvo(&"home_base", target_id, PLAYER_CLAN)
	_push_event("Lieutenant orders strike on %s." % String(target_id), Color(1.0, 0.8, 0.5))

func _fire_raid_salvo(from_lot_id: StringName, target_lot_id: StringName, attacker_clan: StringName) -> void:
	var treb: Node3D = _settlement.get_trebuchet(from_lot_id)
	var target_view: Node3D = _settlement.get_lot_view(target_lot_id)
	if treb == null or target_view == null:
		_push_event("Raid aborted: no trebuchet or target.", Color(1.0, 0.6, 0.5))
		_pending_attack_lots.erase(target_lot_id)
		return
	var target_pos: Vector3 = target_view.global_position
	# Trebuchet animates; emit fire_ready hooks the projectile launch.
	if treb.has_signal("fire_ready") and not treb.fire_ready.is_connected(_on_trebuchet_fire_ready):
		treb.fire_ready.connect(_on_trebuchet_fire_ready.bind(target_lot_id, attacker_clan))
	treb.play_fire_animation(target_pos)

func _on_trebuchet_fire_ready(launch_pos: Vector3, _dir: Vector3, target_lot_id: StringName, attacker_clan: StringName) -> void:
	var target_view: Node3D = _settlement.get_lot_view(target_lot_id)
	if target_view == null:
		_pending_attack_lots.erase(target_lot_id)
		return
	var target_pos: Vector3 = target_view.global_position + Vector3(
		randf_range(-3.0, 3.0), 0.0, randf_range(-3.0, 3.0)
	)
	var distance: float = launch_pos.distance_to(target_pos)
	var flight_time: float = clampf(distance / 28.0, 0.9, 2.4)
	var peak: float = clampf(distance * 0.35, 8.0, 22.0)
	var projectile: Node3D = _settlement.launch_projectile(launch_pos, target_pos, flight_time, peak)
	if projectile and projectile.has_signal("impact"):
		projectile.impact.connect(
			_on_projectile_impact.bind(target_lot_id, attacker_clan), CONNECT_ONE_SHOT
		)

func _on_projectile_impact(world_pos: Vector3, target_lot_id: StringName, attacker_clan: StringName) -> void:
	var tint: Color = FactionPalette.primary_color(attacker_clan)
	_settlement.spawn_battle_puff(world_pos, "POW!", tint)
	_settlement.alert_villagers_at_lot(target_lot_id, 4.0)
	_push_event("Impact! Defenders scatter at %s." % String(target_lot_id), Color(1.0, 0.75, 0.4))
	_pending_attack_lots.erase(target_lot_id)
	# Spawn a live battle at the target lot if one isn't already running.
	if not _settlement.has_active_battle(target_lot_id):
		var lot: LotTypes.LotData = Lots.get_lot_data(target_lot_id)
		var defender_clan: StringName = lot.owning_clan_id if lot else NEUTRAL_CLAN
		_settlement.start_live_battle(target_lot_id, attacker_clan, defender_clan, 5, 4)
		if _hud and _hud.has_method("show_raid_banner"):
			_hud.show_raid_banner(
				"BATTLE AT %s" % String(target_lot_id).to_upper(),
				"Press [G] to drop in as the God-King!",
				Color(1.0, 0.75, 0.35)
			)

func _on_battle_resolved(lot_id: StringName, winning_clan: StringName) -> void:
	_push_event(
		"Battle at %s ends — %s victorious." % [String(lot_id), FactionPalette.clan_display_name(winning_clan)],
		Color(0.9, 0.95, 0.6)
	)
	var lot: LotTypes.LotData = Lots.get_lot_data(lot_id)
	if lot and lot.owning_clan_id != winning_clan:
		Lots.change_lot_owner(lot_id, winning_clan)

func _handle_recruit_complete(_d: DecreeTypes.Decree) -> void:
	_push_event("Recruit complete (hookup pending).", Color(0.8, 0.9, 1.0))

func _on_villager_need_critical(vid: StringName, need: int) -> void:
	var key: String = "%s::%d" % [String(vid), need]
	if _need_warn_cooldowns.get(key, 0.0) > 0.0:
		return
	_need_warn_cooldowns[key] = 5.0
	var v: VillagerTypes.VillagerData = Villagers.get_villager(vid)
	var who: String = v.display_name if v else String(vid)
	var need_name: String = VillagerTypes.VillagerNeed.keys()[need]
	_push_event("%s cries out: %s critical" % [who, need_name], Color(1.0, 0.6, 0.4))

func _on_lot_ownership_changed(lot_id: StringName, new_owner: StringName) -> void:
	if _settlement and _settlement.has_method("recolor_lot"):
		_settlement.recolor_lot(lot_id, new_owner)
	# Forward base: the new owner gets a trebuchet on the captured lot if none exists.
	if new_owner == PLAYER_CLAN or new_owner == RIVAL_CLAN:
		_settlement.spawn_trebuchet(lot_id, new_owner)
	_push_event("%s now flies the %s banner." % [String(lot_id), FactionPalette.clan_display_name(new_owner)], Color(0.6, 1.0, 0.7))

# ---------- Input: debug decree hotkeys 1-4 ----------

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		if _god_king_mode:
			_handle_god_king_input(event)
		return
	var key_event: InputEventKey = event
	match key_event.keycode:
		KEY_1:
			trigger_gather_decree()
		KEY_2:
			trigger_build_decree()
		KEY_3:
			trigger_raid_decree()
		KEY_4:
			trigger_recruit_decree()
		KEY_G:
			_toggle_godking_mode()
		KEY_J:
			if _god_king_mode and _god_king:
				_god_king.swing()
		KEY_K:
			if _god_king_mode and _god_king:
				_god_king.start_parry()
		KEY_I:
			if _god_king_mode and _god_king:
				_god_king.set_stance_by_input(true, false, false)
		KEY_U:
			if _god_king_mode and _god_king:
				_god_king.set_stance_by_input(false, true, false)
		KEY_O:
			if _god_king_mode and _god_king:
				_god_king.set_stance_by_input(false, false, true)

func _process_god_king_input(delta: float) -> void:
	if _god_king == null:
		return
	# Auto-lock on the nearest enemy — god-king faces them, camera follows.
	if _settlement and _settlement.has_method("get_nearest_enemy_to_god_king"):
		var enemy: Node3D = _settlement.get_nearest_enemy_to_god_king()
		if enemy and is_instance_valid(enemy):
			_god_king.face_toward(enemy.global_position, delta)
	# Camera-relative WASD: W = toward where the camera looks, not world-Z.
	var input_fwd: float = 0.0
	var input_right: float = 0.0
	if Input.is_key_pressed(KEY_W):
		input_fwd += 1.0
	if Input.is_key_pressed(KEY_S):
		input_fwd -= 1.0
	if Input.is_key_pressed(KEY_A):
		input_right -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_right += 1.0
	var move: Vector3
	if _chase_camera and is_instance_valid(_chase_camera):
		var cam_basis: Basis = _chase_camera.global_transform.basis
		var cam_fwd: Vector3 = -cam_basis.z
		cam_fwd.y = 0.0
		cam_fwd = cam_fwd.normalized()
		var cam_right: Vector3 = cam_basis.x
		cam_right.y = 0.0
		cam_right = cam_right.normalized()
		move = cam_fwd * input_fwd + cam_right * input_right
	else:
		# Fallback to world-space if no chase camera
		move = Vector3(input_right, 0.0, -input_fwd)
	_god_king.process_movement(delta, move)

func _handle_god_king_input(event: InputEvent) -> void:
	if _god_king == null:
		return
	# Mouse motion → stance selection (For Honor right-stick feel)
	if event is InputEventMouseMotion:
		_god_king.update_stance_from_mouse((event as InputEventMouseMotion).relative)
	# Mouse buttons → swing / parry
	elif event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		var btn: int = (event as InputEventMouseButton).button_index
		if btn == MOUSE_BUTTON_LEFT:
			_god_king.swing()
		elif btn == MOUSE_BUTTON_RIGHT:
			_god_king.start_parry()

# ---------- Public decree triggers (called by HUD buttons + hotkeys) ----------

func trigger_gather_decree() -> void:
	_issue_player_decree(DecreeTypes.DecreeType.GATHER, &"home_base")

func trigger_build_decree() -> void:
	_issue_player_decree(DecreeTypes.DecreeType.BUILD, _pick_build_target_lot())

func trigger_raid_decree() -> void:
	var rival_lots: Array = Lots.get_lots_by_clan(RIVAL_CLAN)
	if rival_lots.is_empty():
		_push_event("No enemy holdings remain to raid.", Color(0.7, 0.7, 0.7))
		return
	# Round-robin target picker so multi-base clan wars hit both lots over time.
	_raid_target_index = (_raid_target_index + 1) % rival_lots.size()
	var target_lot: LotTypes.LotData = rival_lots[_raid_target_index]
	if _pending_attack_lots.get(target_lot.lot_id, false):
		_push_event("A raid on %s is already in the air." % String(target_lot.lot_id), Color(0.8, 0.8, 0.6))
		return
	_pending_attack_lots[target_lot.lot_id] = true
	_issue_player_decree(DecreeTypes.DecreeType.ATTACK, target_lot.lot_id)
	if _hud and _hud.has_method("show_raid_banner"):
		_hud.show_raid_banner(
			"RAID LAUNCHED",
			"Strike on %s!" % String(target_lot.lot_id),
			Color(1.0, 0.55, 0.3)
		)
	var source: StringName = _closest_friendly_lot_to(target_lot.lot_id)
	_fire_raid_salvo(source, target_lot.lot_id, PLAYER_CLAN)

func trigger_recruit_decree() -> void:
	_issue_player_decree(DecreeTypes.DecreeType.RECRUIT, &"home_base")

func _toggle_godking_mode() -> void:
	if not _god_king_mode:
		_enter_godking_mode()
	else:
		_exit_godking_mode()

func _enter_godking_mode() -> void:
	_god_king_mode = true
	# If there's an active battle, drop the god-king into it. Otherwise kick off a
	# fresh assault on the closest enemy lot, spawning his escort + defenders so
	# there are real troops on both sides when he lands.
	var drop_pos: Vector3
	var battle_lot: StringName = _settlement.get_any_active_battle_lot()
	if battle_lot != &"":
		drop_pos = _settlement.get_active_battle_center(battle_lot) + Vector3(5.0, 0.0, 5.0)
		_push_event("The God-King crashes into the battle at %s!" % String(battle_lot), Color(1.0, 0.85, 0.3))
	else:
		var target_lot_id: StringName = _pick_assault_target()
		if target_lot_id != &"":
			var tv: Node3D = _settlement.get_lot_view(target_lot_id)
			drop_pos = tv.global_position + Vector3(5.0, 0.0, 5.0)
			var target_lot: LotTypes.LotData = Lots.get_lot_data(target_lot_id)
			var defender_clan: StringName = target_lot.owning_clan_id if target_lot else NEUTRAL_CLAN
			if not _settlement.has_active_battle(target_lot_id):
				_settlement.start_live_battle(target_lot_id, PLAYER_CLAN, defender_clan, 5, 4)
			_settlement.spawn_battle_puff(tv.global_position + Vector3(0, 1.2, 0), "CHARGE!", Color(1.0, 0.85, 0.3))
			_push_event(
				"The God-King leads the charge on %s!" % String(target_lot_id),
				Color(1.0, 0.85, 0.3)
			)
		else:
			var home_view: Node3D = _settlement.get_lot_view(&"home_base")
			drop_pos = (home_view.global_position if home_view else Vector3.ZERO) + Vector3(6, 0, 6)
			_push_event("The God-King strides onto the field — no foes in sight.", Color(0.9, 0.95, 1.0))
	if _god_king == null:
		_god_king = Node3D.new()
		_god_king.set_script(GodKingViewScript)
		_god_king.name = "GodKing"
		$World.add_child(_god_king)
		_god_king.setup(drop_pos)
	else:
		_god_king.global_position = drop_pos
	if _chase_camera == null:
		_chase_camera = Camera3D.new()
		_chase_camera.set_script(ChaseCameraScript)
		_chase_camera.name = "ChaseCamera"
		$World.add_child(_chase_camera)
	_chase_camera.attach(_god_king)
	_chase_camera.current = true
	# Capture mouse so relative motion drives the stance (like a right stick).
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Wire the God-King into the combat layer so he can kill and be killed.
	if _settlement and _settlement.has_method("set_god_king"):
		_settlement.set_god_king(_god_king)
	if _god_king.has_signal("hit_attempted") and not _god_king.hit_attempted.is_connected(_on_godking_hit):
		_god_king.hit_attempted.connect(_on_godking_hit)
	if _god_king.has_signal("damaged") and not _god_king.damaged.is_connected(_on_godking_damaged):
		_god_king.damaged.connect(_on_godking_damaged)
	if _god_king.has_signal("died") and not _god_king.died.is_connected(_on_godking_died):
		_god_king.died.connect(_on_godking_died)

func _exit_godking_mode() -> void:
	_god_king_mode = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if _orbit_camera:
		_orbit_camera.current = true
	if _settlement and _settlement.has_method("clear_god_king"):
		_settlement.clear_god_king()
	if _god_king:
		if _god_king.hit_attempted.is_connected(_on_godking_hit):
			_god_king.hit_attempted.disconnect(_on_godking_hit)
		if _god_king.damaged.is_connected(_on_godking_damaged):
			_god_king.damaged.disconnect(_on_godking_damaged)
		if _god_king.died.is_connected(_on_godking_died):
			_god_king.died.disconnect(_on_godking_died)
		_god_king.queue_free()
		_god_king = null

func _on_godking_hit(origin: Vector3, forward: Vector3, hit_range: float, arc_deg: float, dmg: float) -> void:
	if _settlement and _settlement.has_method("resolve_god_king_hit"):
		_settlement.resolve_god_king_hit(origin, forward, hit_range, arc_deg, dmg)

func _on_godking_damaged(amount: float, world_pos: Vector3) -> void:
	if _settlement and _settlement.has_method("spawn_damage_number"):
		_settlement.spawn_damage_number(world_pos, amount, Color(1.0, 0.4, 0.35))
	if _chase_camera and _chase_camera.has_method("shake"):
		_chase_camera.shake(0.25)

func _on_godking_died() -> void:
	_push_event("THE GOD-KING HAS FALLEN!", Color(1.0, 0.3, 0.3))
	if _hud and _hud.has_method("show_raid_banner"):
		_hud.show_raid_banner(
			"THE GOD-KING FALLS",
			"The crown rolls in the dust...",
			Color(1.0, 0.3, 0.25)
		)
	_exit_godking_mode()

func _pick_assault_target() -> StringName:
	# Closest enemy (rival) lot to home_base. Falls back to any rival, then empty.
	var home_view: Node3D = _settlement.get_lot_view(&"home_base")
	var home_pos: Vector3 = home_view.global_position if home_view else Vector3.ZERO
	var best: StringName = &""
	var best_dist: float = 1e9
	for lot: LotTypes.LotData in Lots.get_lots_by_clan(RIVAL_CLAN):
		var lv: Node3D = _settlement.get_lot_view(lot.lot_id)
		if lv == null:
			continue
		var d: float = home_pos.distance_to(lv.global_position)
		if d < best_dist:
			best_dist = d
			best = lot.lot_id
	return best

func _issue_player_decree(type: int, target_id: StringName) -> void:
	var d: DecreeTypes.Decree = DecreeTypes.Decree.new(type, target_id, 5)
	Decrees.issue_decree(d)

func _closest_friendly_lot_to(target_lot_id: StringName) -> StringName:
	var target_view: Node3D = _settlement.get_lot_view(target_lot_id)
	if target_view == null:
		return &"home_base"
	var target_pos: Vector3 = target_view.global_position
	var best: StringName = &"home_base"
	var best_dist: float = 1e9
	for lot: LotTypes.LotData in Lots.get_lots_by_clan(PLAYER_CLAN):
		var treb: Node3D = _settlement.get_trebuchet(lot.lot_id)
		if treb == null:
			continue
		var d: float = target_pos.distance_to(treb.global_position)
		if d < best_dist:
			best_dist = d
			best = lot.lot_id
	return best

func _pick_build_target_lot() -> StringName:
	var player_lots: Array = Lots.get_lots_by_clan(PLAYER_CLAN)
	var best: LotTypes.LotData = null
	for lot: LotTypes.LotData in player_lots:
		if best == null:
			best = lot
			continue
		if lot.building_ids.size() < best.building_ids.size():
			best = lot
		elif lot.building_ids.size() == best.building_ids.size() and String(lot.lot_id) < String(best.lot_id):
			best = lot
	return best.lot_id if best else &"home_base"

# ---------- Public accessors for HUD ----------

func get_lieutenants() -> Array[LieutenantAI]:
	return _lieutenants

func get_lieutenant_name(id: StringName) -> String:
	return _lieutenant_names.get(id, String(id))

func get_threat_level() -> float:
	return _rival_civ.threat_level if _rival_civ else 0.0

func get_game_tick_count() -> int:
	return _game_tick_count

func _push_event(text: String, color: Color = Color.WHITE) -> void:
	if _hud and _hud.has_method("push_event"):
		_hud.push_event(text, color)
	else:
		print("[EVENT] ", text)

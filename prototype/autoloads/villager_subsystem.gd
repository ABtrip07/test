extends Node

## World subsystem managing all villagers (off-screen simulation).
## Registered as autoload "Villagers" in project.godot.

signal villager_registered(villager_id: StringName)
signal villager_need_critical(villager_id: StringName, need: VillagerTypes.VillagerNeed)

## All villager data keyed by villager_id.
var _all_villagers: Dictionary = {}

## The global relationship graph.
var relationship_graph: RelationshipGraph = RelationshipGraph.new()

## Need decay rate per tick (how fast needs drop).
const NEED_DECAY_RATE: float = 2.0
## Morale drift speed toward satisfaction.
const MORALE_DRIFT_RATE: float = 1.0
## Faith drift toward piety-weighted target.
const FAITH_DRIFT_RATE: float = 0.5

func reset() -> void:
	_all_villagers.clear()
	relationship_graph = RelationshipGraph.new()

func register_villager(data: VillagerTypes.VillagerData) -> void:
	_all_villagers[data.villager_id] = data
	villager_registered.emit(data.villager_id)

func get_villager(villager_id: StringName) -> VillagerTypes.VillagerData:
	return _all_villagers.get(villager_id, null)

func get_all_villager_ids() -> Array:
	return _all_villagers.keys()

func get_villager_count() -> int:
	return _all_villagers.size()

## Tick all off-screen villagers. delta_time is in game-seconds.
func tick_villagers(delta_time: float) -> void:
	for villager_id: StringName in _all_villagers:
		var v: VillagerTypes.VillagerData = _all_villagers[villager_id]
		_tick_single_villager(v, delta_time)

func _tick_single_villager(v: VillagerTypes.VillagerData, dt: float) -> void:
	# Decay needs over time
	for need_type: int in v.needs:
		v.needs[need_type] = maxf(0.0, v.needs[need_type] - NEED_DECAY_RATE * dt)
		if v.needs[need_type] < 15.0:
			villager_need_critical.emit(v.villager_id, need_type as VillagerTypes.VillagerNeed)

	# Morale drifts toward satisfaction
	var satisfaction: float = v.get_satisfaction()
	v.morale = move_toward(v.morale, satisfaction, MORALE_DRIFT_RATE * dt)

	# Faith drifts based on piety trait
	var faith_target: float = v.piety * 100.0
	v.faith = move_toward(v.faith, faith_target, FAITH_DRIFT_RATE * dt)

## Fulfill a specific need for a villager (e.g., when food is consumed).
func fulfill_need(villager_id: StringName, need: VillagerTypes.VillagerNeed, amount: float) -> void:
	var v: VillagerTypes.VillagerData = _all_villagers.get(villager_id, null)
	if v:
		v.needs[need] = minf(100.0, v.needs.get(need, 0.0) + amount)

## Get summary of all villagers for debug output.
func get_summary() -> String:
	var lines: Array[String] = []
	for vid: StringName in _all_villagers:
		lines.append("  " + _all_villagers[vid].to_string_summary())
	return "Villagers (%d):\n%s" % [_all_villagers.size(), "\n".join(lines)]

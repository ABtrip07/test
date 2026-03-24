extends Node

## Manages the decree queue. Player issues high-level orders;
## lieutenants interpret and execute them.
## Registered as autoload "Decrees" in project.godot.

signal decree_issued(decree: DecreeTypes.Decree)
signal decree_completed(decree: DecreeTypes.Decree)
signal decree_cancelled(target_id: StringName)

var _active_decrees: Array[DecreeTypes.Decree] = []
var _lieutenants: Dictionary = {}  # lieutenant_id -> LieutenantAI
var _game_time: float = 0.0

func reset() -> void:
	_active_decrees.clear()
	_lieutenants.clear()
	_game_time = 0.0

## Register a lieutenant for decree assignment.
func register_lieutenant(lt: LieutenantAI) -> void:
	_lieutenants[lt.lieutenant_id] = lt

## Issue a new decree from the God-King.
func issue_decree(decree: DecreeTypes.Decree) -> void:
	decree.time_issued = _game_time
	_active_decrees.append(decree)
	_assign_decree_to_best_lieutenant(decree)
	decree_issued.emit(decree)

## Cancel a decree by target ID.
func cancel_decree(target_id: StringName) -> void:
	_active_decrees = _active_decrees.filter(
		func(d: DecreeTypes.Decree) -> bool: return d.target_id != target_id
	)
	decree_cancelled.emit(target_id)

## Get all active (non-complete) decrees sorted by priority descending.
func get_active_decrees() -> Array[DecreeTypes.Decree]:
	var sorted: Array[DecreeTypes.Decree] = _active_decrees.duplicate()
	sorted.sort_custom(func(a: DecreeTypes.Decree, b: DecreeTypes.Decree) -> bool:
		return a.priority > b.priority
	)
	return sorted

## Tick all decrees and lieutenants.
func tick_decrees(delta_time: float) -> void:
	_game_time += delta_time
	# Tick all lieutenants
	for lt_id: StringName in _lieutenants:
		var lt: LieutenantAI = _lieutenants[lt_id]
		lt.tick_ai(delta_time)
	# Check for completed decrees
	var completed: Array[DecreeTypes.Decree] = []
	for decree: DecreeTypes.Decree in _active_decrees:
		if decree.is_complete():
			completed.append(decree)
	for decree: DecreeTypes.Decree in completed:
		_active_decrees.erase(decree)
		decree_completed.emit(decree)

## Find the best lieutenant for a decree and assign it.
func _assign_decree_to_best_lieutenant(decree: DecreeTypes.Decree) -> void:
	var best_lt: LieutenantAI = null
	var best_score: float = -1.0
	for lt_id: StringName in _lieutenants:
		var lt: LieutenantAI = _lieutenants[lt_id]
		var score: float = lt.get_suitability_for(decree)
		if score > best_score:
			best_score = score
			best_lt = lt
	if best_lt:
		best_lt.assign_decree(decree)
		decree.assigned_lieutenant_id = best_lt.lieutenant_id

func get_summary() -> String:
	var lines: Array[String] = []
	for d: DecreeTypes.Decree in _active_decrees:
		lines.append("  " + d.to_string_summary())
	return "Active Decrees (%d):\n%s" % [_active_decrees.size(), "\n".join(lines)]

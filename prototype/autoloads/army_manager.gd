extends Node

## Manages all squads and army composition.
## Registered as autoload "Army" in project.godot.

signal squad_registered(squad_id: StringName)

var _squads: Dictionary = {}  # squad_id -> SquadData

func reset() -> void:
	_squads.clear()

func register_squad(squad: SquadTypes.SquadData) -> void:
	_squads[squad.squad_id] = squad
	squad_registered.emit(squad.squad_id)

func get_squad(squad_id: StringName) -> SquadTypes.SquadData:
	return _squads.get(squad_id, null)

func get_squads_by_lieutenant(lieutenant_id: StringName) -> Array[SquadTypes.SquadData]:
	var result: Array[SquadTypes.SquadData] = []
	for squad: SquadTypes.SquadData in _squads.values():
		if squad.lieutenant_id == lieutenant_id:
			result.append(squad)
	return result

func get_total_army_power() -> float:
	var total: float = 0.0
	for squad: SquadTypes.SquadData in _squads.values():
		total += squad.get_effective_combat_power()
	return total

func apply_casualties(squad_id: StringName, casualties: int) -> void:
	var squad: SquadTypes.SquadData = _squads.get(squad_id, null)
	if squad:
		squad.unit_count = maxi(0, squad.unit_count - casualties)

func get_summary() -> String:
	var lines: Array[String] = []
	for squad: SquadTypes.SquadData in _squads.values():
		lines.append("  " + squad.to_string_summary())
	return "Army (power=%.1f):\n%s" % [get_total_army_power(), "\n".join(lines)]

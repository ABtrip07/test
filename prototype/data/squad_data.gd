class_name SquadTypes

## Represents a squad of Junkbots.
class SquadData:
	var squad_id: StringName
	var lieutenant_id: StringName
	var unit_count: int
	var morale_modifier: float

	func _init(p_id: StringName = &"", p_lt: StringName = &"", p_count: int = 10) -> void:
		squad_id = p_id
		lieutenant_id = p_lt
		unit_count = p_count
		morale_modifier = 1.0

	func get_effective_combat_power() -> float:
		return float(unit_count) * morale_modifier

	func to_string_summary() -> String:
		return "Squad(%s units=%d power=%.1f)" % [squad_id, unit_count, get_effective_combat_power()]

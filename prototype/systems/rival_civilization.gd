class_name RivalCivilization

## Represents a rival AI civilization on the world map.

var civilization_id: StringName
var civilization_name: String
var threat_level: float
var hostility: float

func _init(p_id: StringName = &"", p_name: String = "", p_threat: float = 0.0) -> void:
	civilization_id = p_id
	civilization_name = p_name
	threat_level = p_threat
	hostility = 50.0

## Tick: threat grows over time, hostility drifts.
func tick_civilization(delta_time: float) -> void:
	threat_level += 0.5 * delta_time
	hostility = minf(100.0, hostility + 0.1 * delta_time)

func to_string_summary() -> String:
	return "Rival(%s threat=%.1f hostility=%.1f)" % [civilization_name, threat_level, hostility]

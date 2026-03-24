class_name CombatResult

## Result of a combat engagement.
var attacker_won: bool
var attacker_casualties: int
var defender_casualties: int

func _init() -> void:
	attacker_won = false
	attacker_casualties = 0
	defender_casualties = 0

func to_string_summary() -> String:
	var winner: String = "ATTACKER" if attacker_won else "DEFENDER"
	return "CombatResult(winner=%s atk_lost=%d def_lost=%d)" % [
		winner, attacker_casualties, defender_casualties
	]

class_name CombatResolver

## Resolves combat between squads using power calculations and RNG.
## Static utility class -- maps to UE5 UCombatResolver.

## Resolve a battle between attacker and defender squad arrays.
static func resolve_combat(
	attackers: Array[SquadTypes.SquadData],
	defenders: Array[SquadTypes.SquadData]
) -> CombatResult:
	var result: CombatResult = CombatResult.new()

	var atk_power: float = _calculate_total_power(attackers)
	var def_power: float = _calculate_total_power(defenders)

	if atk_power <= 0.0 and def_power <= 0.0:
		return result

	# Power ratio determines outcome probability
	var total: float = atk_power + def_power
	var atk_ratio: float = atk_power / total if total > 0.0 else 0.5

	# Add randomness: roll against ratio
	var roll: float = randf()
	result.attacker_won = roll < atk_ratio

	# Casualties based on relative power (loser suffers more)
	var atk_total_units: int = _count_total_units(attackers)
	var def_total_units: int = _count_total_units(defenders)

	if result.attacker_won:
		result.defender_casualties = ceili(def_total_units * randf_range(0.4, 0.7))
		result.attacker_casualties = ceili(atk_total_units * randf_range(0.1, 0.3))
	else:
		result.attacker_casualties = ceili(atk_total_units * randf_range(0.4, 0.7))
		result.defender_casualties = ceili(def_total_units * randf_range(0.1, 0.3))

	return result

static func _calculate_total_power(squads: Array[SquadTypes.SquadData]) -> float:
	var total: float = 0.0
	for squad: SquadTypes.SquadData in squads:
		total += squad.get_effective_combat_power()
	return total

static func _count_total_units(squads: Array[SquadTypes.SquadData]) -> int:
	var total: int = 0
	for squad: SquadTypes.SquadData in squads:
		total += squad.unit_count
	return total

class_name VillagerTypes

## Villager needs that drive behavior.
enum VillagerNeed {
	FOOD,
	SHELTER,
	SAFETY,
	SOCIAL,
	FAITH,
	PURPOSE,
}

## Lightweight data representation for off-screen villagers.
## Maps to UE5 FVillagerData USTRUCT.
class VillagerData:
	var villager_id: StringName
	var display_name: String
	var last_known_location: Vector2
	var needs: Dictionary  # VillagerNeed -> float
	var assigned_lot_id: StringName
	var clan_id: StringName
	var faith: float
	var morale: float

	## Personality traits embedded directly (no separate DataAsset in prototype).
	var courage: float
	var loyalty: float
	var industriousness: float
	var sociability: float
	var piety: float

	func _init(p_id: StringName = &"", p_name: String = "") -> void:
		villager_id = p_id
		display_name = p_name
		last_known_location = Vector2.ZERO
		needs = {}
		assigned_lot_id = &""
		clan_id = &""
		faith = 50.0
		morale = 50.0
		courage = 0.5
		loyalty = 0.5
		industriousness = 0.5
		sociability = 0.5
		piety = 0.5
		_init_needs()

	func _init_needs() -> void:
		for need_type: int in VillagerNeed.values():
			needs[need_type] = 50.0

	## Calculate overall satisfaction (0-100). Used for morale drift.
	func get_satisfaction() -> float:
		if needs.is_empty():
			return 50.0
		var total: float = 0.0
		for value: float in needs.values():
			total += value
		return total / needs.size()

	## Returns a summary string for debug output.
	func to_string_summary() -> String:
		return "%s (morale=%.1f faith=%.1f satisfaction=%.1f)" % [
			display_name, morale, faith, get_satisfaction()
		]

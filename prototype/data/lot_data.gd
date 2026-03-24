class_name LotTypes

## Serializable data chunk representing a single lot in the world.
class LotData:
	var lot_id: StringName
	var world_position: Vector2
	var owning_clan_id: StringName
	var building_ids: Array[StringName]
	var assigned_villager_ids: Array[StringName]
	var defense_rating: float

	func _init(p_id: StringName = &"", p_pos: Vector2 = Vector2.ZERO) -> void:
		lot_id = p_id
		world_position = p_pos
		owning_clan_id = &""
		building_ids = []
		assigned_villager_ids = []
		defense_rating = 0.0

	func to_string_summary() -> String:
		return "Lot(%s owner=%s buildings=%d villagers=%d defense=%.1f)" % [
			lot_id, owning_clan_id, building_ids.size(), assigned_villager_ids.size(), defense_rating
		]

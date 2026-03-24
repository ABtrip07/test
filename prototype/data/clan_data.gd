class_name ClanTypes

## Data for a 5-person clan unit.
class ClanData:
	var clan_id: StringName
	var clan_name: String
	var member_ids: Array[StringName]  # Max 5
	var coalition_id: StringName
	var clan_loyalty: float

	func _init(p_id: StringName = &"", p_name: String = "") -> void:
		clan_id = p_id
		clan_name = p_name
		member_ids = []
		coalition_id = &""
		clan_loyalty = 50.0

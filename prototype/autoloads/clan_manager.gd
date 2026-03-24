extends Node

## Manages clans (5-person units) and coalitions.
## Registered as autoload "Clans" in project.godot.

var _clans: Dictionary = {}  # clan_id -> ClanData

func reset() -> void:
	_clans.clear()

func register_clan(data: ClanTypes.ClanData) -> void:
	_clans[data.clan_id] = data

func get_clan_data(clan_id: StringName) -> ClanTypes.ClanData:
	return _clans.get(clan_id, null)

func get_all_clans() -> Array:
	return _clans.values()

func add_member_to_clan(villager_id: StringName, clan_id: StringName) -> bool:
	var clan: ClanTypes.ClanData = _clans.get(clan_id, null)
	if clan and clan.member_ids.size() < 5 and villager_id not in clan.member_ids:
		clan.member_ids.append(villager_id)
		return true
	return false

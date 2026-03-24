extends Node

## Manages the lot-based territory system.
## Registered as autoload "Lots" in project.godot.

signal lot_registered(lot_id: StringName)
signal lot_ownership_changed(lot_id: StringName, new_owner: StringName)

var _lots: Dictionary = {}

func reset() -> void:
	_lots.clear()

func register_lot(data: LotTypes.LotData) -> void:
	_lots[data.lot_id] = data
	lot_registered.emit(data.lot_id)

func get_lot_data(lot_id: StringName) -> LotTypes.LotData:
	return _lots.get(lot_id, null)

func get_lots_by_clan(clan_id: StringName) -> Array[LotTypes.LotData]:
	var result: Array[LotTypes.LotData] = []
	for lot: LotTypes.LotData in _lots.values():
		if lot.owning_clan_id == clan_id:
			result.append(lot)
	return result

func get_all_lots() -> Array:
	return _lots.values()

func assign_villager_to_lot(villager_id: StringName, lot_id: StringName) -> void:
	var lot: LotTypes.LotData = _lots.get(lot_id, null)
	if lot and villager_id not in lot.assigned_villager_ids:
		lot.assigned_villager_ids.append(villager_id)

func add_building_to_lot(building_id: StringName, lot_id: StringName) -> void:
	var lot: LotTypes.LotData = _lots.get(lot_id, null)
	if lot and building_id not in lot.building_ids:
		lot.building_ids.append(building_id)

func change_lot_owner(lot_id: StringName, new_clan_id: StringName) -> void:
	var lot: LotTypes.LotData = _lots.get(lot_id, null)
	if lot:
		lot.owning_clan_id = new_clan_id
		lot_ownership_changed.emit(lot_id, new_clan_id)

func get_summary() -> String:
	var lines: Array[String] = []
	for lot: LotTypes.LotData in _lots.values():
		lines.append("  " + lot.to_string_summary())
	return "Lots (%d):\n%s" % [_lots.size(), "\n".join(lines)]

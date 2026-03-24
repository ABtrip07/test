class_name EconomyTicker

## Handles per-tick resource production and consumption.
## This system does not exist as a standalone class in UE5 yet;
## it emerges from the building/villager/resource interaction.
## In the prototype we make it explicit for testability.

## All buildings in the settlement, keyed by building_id.
var _buildings: Dictionary = {}

func register_building(building: BuildingTypes.BuildingData) -> void:
	_buildings[building.building_id] = building

func get_building(building_id: StringName) -> BuildingTypes.BuildingData:
	return _buildings.get(building_id, null)

func get_all_buildings() -> Array:
	return _buildings.values()

## Tick the economy: buildings with workers produce resources, villagers consume food.
func tick_economy(
	delta_time: float,
	resource_sub: Node,
	villager_sub: Node
) -> Dictionary:
	var report: Dictionary = {
		"produced": {},
		"consumed": {},
		"food_shortage": false,
	}

	# --- PRODUCTION: each constructed building with workers produces resources ---
	for building: BuildingTypes.BuildingData in _buildings.values():
		if not building.is_constructed:
			continue
		var production: Array = building.get_production_per_worker()
		if production.is_empty():
			continue
		var res_type: ResourceTypes.ResourceType = production[0] as ResourceTypes.ResourceType
		var per_worker: float = production[1] as float

		# Each worker's output is scaled by their industriousness
		var total_output: float = 0.0
		for wid: StringName in building.assigned_worker_ids:
			var v: VillagerTypes.VillagerData = villager_sub.get_villager(wid)
			var multiplier: float = PersonalityData.get_work_multiplier(v) if v else 1.0
			total_output += per_worker * multiplier * delta_time
		if total_output > 0.0:
			resource_sub.add_resource(res_type, total_output)
			report["produced"][res_type] = report["produced"].get(res_type, 0.0) + total_output

	# --- CONSUMPTION: each villager eats food ---
	var food_per_villager: float = 1.0 * delta_time
	var villager_ids: Array = villager_sub.get_all_villager_ids()
	var total_food_needed: float = villager_ids.size() * food_per_villager
	var food_available: float = resource_sub.get_resource(ResourceTypes.ResourceType.FOOD)

	if food_available >= total_food_needed:
		resource_sub.consume_resource(ResourceTypes.ResourceType.FOOD, total_food_needed)
		report["consumed"][ResourceTypes.ResourceType.FOOD] = total_food_needed
		for vid: StringName in villager_ids:
			villager_sub.fulfill_need(vid, VillagerTypes.VillagerNeed.FOOD, 20.0 * delta_time)
	else:
		resource_sub.consume_resource(ResourceTypes.ResourceType.FOOD, food_available)
		report["consumed"][ResourceTypes.ResourceType.FOOD] = food_available
		report["food_shortage"] = true
		var fed_count: int = floori(food_available / food_per_villager) if food_per_villager > 0.0 else 0
		for i: int in range(mini(fed_count, villager_ids.size())):
			villager_sub.fulfill_need(villager_ids[i], VillagerTypes.VillagerNeed.FOOD, 10.0 * delta_time)

	return report

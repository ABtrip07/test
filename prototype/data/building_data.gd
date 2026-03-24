class_name BuildingTypes

## Building type enumeration.
enum BuildingType {
	SCRAP_YARD,      # Produces Scrap
	FUEL_REFINERY,   # Produces Fuel
	ALCHEMY_LAB,     # Produces Reagents (Sigil)
	DATA_CORE,       # Produces Data (Quantist)
	FARM,            # Produces Food
	BARRACKS,        # Recruits squads
	SHRINE,          # Boosts Faith
	TAVERN,          # Boosts Morale/Social
	WALL,            # Boosts lot defense
}

## Data-only building representation.
class BuildingData:
	var building_id: StringName
	var building_name: String
	var building_type: BuildingType
	var max_workers: int
	var assigned_worker_ids: Array[StringName]
	var lot_id: StringName
	var is_constructed: bool

	func _init(p_id: StringName = &"", p_type: BuildingType = BuildingType.SCRAP_YARD) -> void:
		building_id = p_id
		building_name = BuildingType.keys()[p_type]
		building_type = p_type
		max_workers = 3
		assigned_worker_ids = []
		lot_id = &""
		is_constructed = false

	## Get production output per tick per worker, as [ResourceType, amount].
	func get_production_per_worker() -> Array:
		match building_type:
			BuildingType.SCRAP_YARD:
				return [ResourceTypes.ResourceType.SCRAP, 2.0]
			BuildingType.FUEL_REFINERY:
				return [ResourceTypes.ResourceType.FUEL, 1.5]
			BuildingType.ALCHEMY_LAB:
				return [ResourceTypes.ResourceType.REAGENTS, 1.0]
			BuildingType.DATA_CORE:
				return [ResourceTypes.ResourceType.DATA, 1.0]
			BuildingType.FARM:
				return [ResourceTypes.ResourceType.FOOD, 3.0]
			_:
				return []

	func to_string_summary() -> String:
		return "Building(%s type=%s workers=%d/%d)" % [
			building_id, BuildingType.keys()[building_type],
			assigned_worker_ids.size(), max_workers
		]

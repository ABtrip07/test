class_name PersonalityData

## Personality traits that influence villager behavior and relationships.
## In UE5 this is a UDataAsset; in prototype it is generated randomly.

## Generate random personality traits for a villager.
static func randomize_traits(data: VillagerTypes.VillagerData) -> void:
	data.courage = randf()
	data.loyalty = randf()
	data.industriousness = randf()
	data.sociability = randf()
	data.piety = randf()

## Get a trait-weighted work output multiplier.
static func get_work_multiplier(data: VillagerTypes.VillagerData) -> float:
	return 0.5 + data.industriousness * 0.5

## Get a trait-weighted combat willingness (0-1).
static func get_combat_willingness(data: VillagerTypes.VillagerData) -> float:
	return (data.courage * 0.6 + data.loyalty * 0.4)

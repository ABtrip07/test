class_name WorldSeed

## Static seeder for the MVP. Mutates autoload singletons directly.
## Called from GameController._ready once, after autoloads reset.

static func seed_world(economy: EconomyTicker) -> Dictionary:
	_seed_clans()
	_seed_lots()
	var villager_ids: Array[StringName] = _seed_villagers()
	_seed_buildings(economy)
	var lts: Array[LieutenantAI] = _seed_lieutenants()
	_seed_squads(lts)
	_seed_starting_resources()
	_seed_starting_decree()
	return {
		"lieutenants": lts,
		"villager_ids": villager_ids,
	}

static func _seed_clans() -> void:
	var chosen: ClanTypes.ClanData = ClanTypes.ClanData.new(FactionPalette.CHOSEN, "The Sigil")
	Clans.register_clan(chosen)
	var rival: ClanTypes.ClanData = ClanTypes.ClanData.new(FactionPalette.RIVAL, "The Quantists")
	Clans.register_clan(rival)
	var neutral: ClanTypes.ClanData = ClanTypes.ClanData.new(FactionPalette.NEUTRAL, "The Wasters")
	Clans.register_clan(neutral)

static func _seed_lots() -> void:
	for row: Dictionary in LotLayout.get_lot_grid():
		var lot: LotTypes.LotData = LotTypes.LotData.new(row["id"] as StringName, row["pos"] as Vector2)
		lot.owning_clan_id = row["clan"] as StringName
		Lots.register_lot(lot)

static func _seed_villagers() -> Array[StringName]:
	var ids: Array[StringName] = []
	var roster: Array = [
		{ "id": &"v_0", "name": "Asha",  "clan": FactionPalette.CHOSEN, "lot": &"home_base" },
		{ "id": &"v_1", "name": "Bram",  "clan": FactionPalette.CHOSEN, "lot": &"home_base" },
		{ "id": &"v_2", "name": "Celi",  "clan": FactionPalette.CHOSEN, "lot": &"lot_2" },
		{ "id": &"v_3", "name": "Dax",   "clan": FactionPalette.CHOSEN, "lot": &"lot_2" },
		{ "id": &"v_4", "name": "Vex",   "clan": FactionPalette.RIVAL,  "lot": &"lot_5" },
		{ "id": &"v_5", "name": "Yul",   "clan": FactionPalette.RIVAL,  "lot": &"lot_6" },
	]
	for row: Dictionary in roster:
		var v: VillagerTypes.VillagerData = VillagerTypes.VillagerData.new(row["id"] as StringName, row["name"] as String)
		PersonalityData.randomize_traits(v)
		v.industriousness = maxf(v.industriousness, 0.6)
		v.clan_id = row["clan"] as StringName
		v.assigned_lot_id = row["lot"] as StringName
		Villagers.register_villager(v)
		Clans.add_member_to_clan(v.villager_id, v.clan_id)
		Lots.assign_villager_to_lot(v.villager_id, v.assigned_lot_id)
		ids.append(v.villager_id)
	return ids

static func _seed_buildings(economy: EconomyTicker) -> void:
	# Player: farm on home_base, scrap yard on lot_2
	var farm: BuildingTypes.BuildingData = BuildingTypes.BuildingData.new(&"main_farm", BuildingTypes.BuildingType.FARM)
	farm.is_constructed = true
	farm.lot_id = &"home_base"
	farm.assigned_worker_ids = [&"v_0", &"v_1"]
	economy.register_building(farm)
	Lots.add_building_to_lot(farm.building_id, farm.lot_id)

	var yard: BuildingTypes.BuildingData = BuildingTypes.BuildingData.new(&"main_yard", BuildingTypes.BuildingType.SCRAP_YARD)
	yard.is_constructed = true
	yard.lot_id = &"lot_2"
	yard.assigned_worker_ids = [&"v_2", &"v_3"]
	economy.register_building(yard)
	Lots.add_building_to_lot(yard.building_id, yard.lot_id)

	# Rival: pre-seeded tech spires on their lots (visual only, no workers)
	var spire1: BuildingTypes.BuildingData = BuildingTypes.BuildingData.new(&"rival_spire_1", BuildingTypes.BuildingType.DATA_CORE)
	spire1.is_constructed = true
	spire1.lot_id = &"lot_5"
	economy.register_building(spire1)
	Lots.add_building_to_lot(spire1.building_id, spire1.lot_id)

	var spire2: BuildingTypes.BuildingData = BuildingTypes.BuildingData.new(&"rival_spire_2", BuildingTypes.BuildingType.DATA_CORE)
	spire2.is_constructed = true
	spire2.lot_id = &"lot_6"
	economy.register_building(spire2)
	Lots.add_building_to_lot(spire2.building_id, spire2.lot_id)

static func _seed_lieutenants() -> Array[LieutenantAI]:
	var lts: Array[LieutenantAI] = []
	var ruhan: LieutenantAI = LieutenantAI.new(&"lt_ruhan", 0.75, 0.9)
	var mox: LieutenantAI = LieutenantAI.new(&"lt_mox", 0.55, 0.6)
	Decrees.register_lieutenant(ruhan)
	Decrees.register_lieutenant(mox)
	lts.append(ruhan)
	lts.append(mox)
	return lts

static func _seed_squads(lts: Array[LieutenantAI]) -> void:
	Army.register_squad(SquadTypes.SquadData.new(&"squad_alpha", &"lt_ruhan", 12))
	Army.register_squad(SquadTypes.SquadData.new(&"squad_bravo", &"lt_mox", 10))
	Army.register_squad(SquadTypes.SquadData.new(&"rival_garrison_1", &"rival_ai", 8))

static func _seed_starting_resources() -> void:
	Resources.add_resource(ResourceTypes.ResourceType.FOOD, 200.0)
	Resources.add_resource(ResourceTypes.ResourceType.SCRAP, 80.0)
	Resources.add_resource(ResourceTypes.ResourceType.FUEL, 20.0)

static func _seed_starting_decree() -> void:
	var d: DecreeTypes.Decree = DecreeTypes.Decree.new(DecreeTypes.DecreeType.GATHER, &"home_base", 5)
	Decrees.issue_decree(d)

## Display name lookup for lieutenants (HUD).
static func lieutenant_display_names() -> Dictionary:
	return {
		&"lt_ruhan": "Ruhan the Steady",
		&"lt_mox": "Mox the Bold",
	}

## Lot -> defender squad ids mapping (MVP-static; used for combat lookups).
static func lot_squads_map() -> Dictionary:
	return {
		&"lot_5": [&"rival_garrison_1"],
	}

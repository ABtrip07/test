extends Node

## Headless test runner that exercises all gameplay systems.
## Run with: godot --headless --path prototype -s tests/test_main.gd

var resources: Node
var villagers: Node
var decrees: Node
var lots: Node
var army: Node
var clans: Node
var economy: EconomyTicker

var _test_count: int = 0
var _pass_count: int = 0
var _fail_count: int = 0

func _ready() -> void:
	_setup_subsystems()
	_run_all_tests()
	_print_results()
	get_tree().quit(0 if _fail_count == 0 else 1)

func _setup_subsystems() -> void:
	resources = load("res://autoloads/resource_subsystem.gd").new()
	resources.name = "Resources"
	add_child(resources)

	villagers = load("res://autoloads/villager_subsystem.gd").new()
	villagers.name = "Villagers"
	add_child(villagers)

	decrees = load("res://autoloads/decree_system.gd").new()
	decrees.name = "Decrees"
	add_child(decrees)

	lots = load("res://autoloads/lot_system.gd").new()
	lots.name = "Lots"
	add_child(lots)

	army = load("res://autoloads/army_manager.gd").new()
	army.name = "Army"
	add_child(army)

	clans = load("res://autoloads/clan_manager.gd").new()
	clans.name = "Clans"
	add_child(clans)

	economy = EconomyTicker.new()

func _run_all_tests() -> void:
	print("=" .repeat(60))
	print("THE LAST COLLECTIVE - Prototype System Tests")
	print("=" .repeat(60))
	print("")

	test_resource_system()
	test_villager_registration_and_needs()
	test_relationship_graph()
	test_lot_system()
	test_clan_system()
	test_decree_system_with_lieutenants()
	test_economy_production()
	test_combat_resolver()
	test_full_game_loop()

func _print_results() -> void:
	print("")
	print("=" .repeat(60))
	print("RESULTS: %d/%d tests passed, %d failed" % [_pass_count, _test_count, _fail_count])
	print("=" .repeat(60))

# ---------- Assertion helpers ----------

func _assert(condition: bool, description: String) -> void:
	_test_count += 1
	if condition:
		_pass_count += 1
		print("  PASS: %s" % description)
	else:
		_fail_count += 1
		print("  FAIL: %s" % description)

func _section(name: String) -> void:
	print("\n--- %s ---" % name)

# ---------- Tests ----------

func test_resource_system() -> void:
	_section("Resource System")
	resources.reset()

	resources.add_resource(ResourceTypes.ResourceType.SCRAP, 100.0)
	_assert(resources.get_resource(ResourceTypes.ResourceType.SCRAP) == 100.0,
		"Add 100 scrap -> get 100")

	var consumed: bool = resources.consume_resource(ResourceTypes.ResourceType.SCRAP, 40.0)
	_assert(consumed, "Consume 40 scrap succeeds")
	_assert(resources.get_resource(ResourceTypes.ResourceType.SCRAP) == 60.0,
		"After consuming 40 scrap, 60 remains")

	var over_consume: bool = resources.consume_resource(ResourceTypes.ResourceType.SCRAP, 100.0)
	_assert(not over_consume, "Cannot consume 100 scrap when only 60 available")

	var cost: Array = [
		ResourceTypes.ResourceAmount.new(ResourceTypes.ResourceType.SCRAP, 30.0),
		ResourceTypes.ResourceAmount.new(ResourceTypes.ResourceType.FUEL, 10.0),
	]
	_assert(not resources.can_afford(cost), "Cannot afford scrap+fuel (no fuel)")
	resources.add_resource(ResourceTypes.ResourceType.FUEL, 20.0)
	_assert(resources.can_afford(cost), "Can afford after adding fuel")

	print("  Resources: %s" % resources.get_all_resources_summary())

func test_villager_registration_and_needs() -> void:
	_section("Villager Simulation")
	villagers.reset()

	for i: int in range(5):
		var v: VillagerTypes.VillagerData = VillagerTypes.VillagerData.new(
			StringName("villager_%d" % i),
			"Villager %d" % i
		)
		PersonalityData.randomize_traits(v)
		villagers.register_villager(v)

	_assert(villagers.get_villager_count() == 5, "Registered 5 villagers")

	var v0: VillagerTypes.VillagerData = villagers.get_villager(&"villager_0")
	_assert(v0 != null, "Can retrieve villager_0")
	_assert(v0.get_satisfaction() == 50.0, "Initial satisfaction is 50.0")

	villagers.tick_villagers(5.0)
	var v0_after: VillagerTypes.VillagerData = villagers.get_villager(&"villager_0")
	_assert(v0_after.get_satisfaction() < 50.0, "Satisfaction decreased after 5s tick")

	villagers.fulfill_need(&"villager_0", VillagerTypes.VillagerNeed.FOOD, 30.0)
	var food_need: float = v0_after.needs[VillagerTypes.VillagerNeed.FOOD]
	_assert(food_need > 40.0, "Food need increased after fulfillment")

	print(villagers.get_summary())

func test_relationship_graph() -> void:
	_section("Relationship Graph")
	var graph: RelationshipGraph = RelationshipGraph.new()

	graph.set_relationship(&"v1", &"v2", 50.0, 80.0)
	graph.set_relationship(&"v1", &"v3", -20.0, 30.0)
	graph.set_relationship(&"v2", &"v1", 60.0, 90.0)

	var edge: RelationshipGraph.RelationshipEdge = graph.get_relationship(&"v1", &"v2")
	_assert(edge != null, "v1->v2 relationship exists")
	_assert(edge.affinity == 50.0, "v1->v2 affinity is 50")
	_assert(edge.trust == 80.0, "v1->v2 trust is 80")

	var no_edge: RelationshipGraph.RelationshipEdge = graph.get_relationship(&"v3", &"v1")
	_assert(no_edge == null, "v3->v1 relationship does not exist (directed)")

	var v1_rels: Array = graph.get_relationships_for(&"v1")
	_assert(v1_rels.size() == 2, "v1 has 2 outgoing relationships")

func test_lot_system() -> void:
	_section("Lot System")
	lots.reset()

	var lot1: LotTypes.LotData = LotTypes.LotData.new(&"lot_1", Vector2(0, 0))
	lot1.owning_clan_id = &"player_clan"
	lots.register_lot(lot1)

	var lot2: LotTypes.LotData = LotTypes.LotData.new(&"lot_2", Vector2(100, 0))
	lot2.owning_clan_id = &"rival_clan"
	lots.register_lot(lot2)

	var player_lots: Array = lots.get_lots_by_clan(&"player_clan")
	_assert(player_lots.size() == 1, "Player owns 1 lot")

	lots.assign_villager_to_lot(&"villager_0", &"lot_1")
	var l1: LotTypes.LotData = lots.get_lot_data(&"lot_1")
	_assert(l1.assigned_villager_ids.size() == 1, "Lot 1 has 1 assigned villager")

	lots.change_lot_owner(&"lot_2", &"player_clan")
	player_lots = lots.get_lots_by_clan(&"player_clan")
	_assert(player_lots.size() == 2, "Player now owns 2 lots after conquest")

	print(lots.get_summary())

func test_clan_system() -> void:
	_section("Clan System")
	clans.reset()

	var clan: ClanTypes.ClanData = ClanTypes.ClanData.new(&"player_clan", "The Chosen")
	clans.register_clan(clan)

	for i: int in range(5):
		clans.add_member_to_clan(StringName("villager_%d" % i), &"player_clan")
	var clan_data: ClanTypes.ClanData = clans.get_clan_data(&"player_clan")
	_assert(clan_data.member_ids.size() == 5, "Clan has 5 members (max)")

	var overflow: bool = clans.add_member_to_clan(&"villager_extra", &"player_clan")
	_assert(not overflow, "Cannot add 6th member to clan (max 5)")

func test_decree_system_with_lieutenants() -> void:
	_section("Decree System + Lieutenants")
	decrees.reset()

	var lt1: LieutenantAI = LieutenantAI.new(&"lt_1", 0.8, 0.9)
	var lt2: LieutenantAI = LieutenantAI.new(&"lt_2", 0.4, 0.6)
	decrees.register_lieutenant(lt1)
	decrees.register_lieutenant(lt2)

	var gather_decree: DecreeTypes.Decree = DecreeTypes.Decree.new(
		DecreeTypes.DecreeType.GATHER, &"lot_1", 5
	)
	decrees.issue_decree(gather_decree)

	_assert(gather_decree.assigned_lieutenant_id != &"",
		"Decree was assigned to a lieutenant")
	print("  Gather decree assigned to: %s" % gather_decree.assigned_lieutenant_id)

	var attack_decree: DecreeTypes.Decree = DecreeTypes.Decree.new(
		DecreeTypes.DecreeType.ATTACK, &"rival_territory", 10
	)
	decrees.issue_decree(attack_decree)

	_assert(decrees.get_active_decrees().size() == 2, "2 active decrees")

	for tick: int in range(20):
		decrees.tick_decrees(1.0)

	var remaining: Array = decrees.get_active_decrees()
	var completed_count: int = 2 - remaining.size()
	_assert(completed_count > 0, "At least 1 decree completed after 20 ticks")
	print("  After 20 ticks: %d completed, %d remaining" % [completed_count, remaining.size()])
	print(decrees.get_summary())

func test_economy_production() -> void:
	_section("Economy Ticker")
	resources.reset()
	villagers.reset()

	resources.add_resource(ResourceTypes.ResourceType.FOOD, 100.0)

	for i: int in range(3):
		var v: VillagerTypes.VillagerData = VillagerTypes.VillagerData.new(
			StringName("worker_%d" % i), "Worker %d" % i
		)
		v.industriousness = 0.8
		villagers.register_villager(v)

	var farm: BuildingTypes.BuildingData = BuildingTypes.BuildingData.new(&"farm_1", BuildingTypes.BuildingType.FARM)
	farm.is_constructed = true
	farm.assigned_worker_ids = [&"worker_0", &"worker_1"]
	economy.register_building(farm)

	var yard: BuildingTypes.BuildingData = BuildingTypes.BuildingData.new(&"yard_1", BuildingTypes.BuildingType.SCRAP_YARD)
	yard.is_constructed = true
	yard.assigned_worker_ids = [&"worker_2"]
	economy.register_building(yard)

	var report: Dictionary = economy.tick_economy(1.0, resources, villagers)

	var food_produced: float = report["produced"].get(ResourceTypes.ResourceType.FOOD, 0.0)
	_assert(food_produced > 0.0, "Farm produced food: %.2f" % food_produced)

	var scrap_produced: float = report["produced"].get(ResourceTypes.ResourceType.SCRAP, 0.0)
	_assert(scrap_produced > 0.0, "Scrap yard produced scrap: %.2f" % scrap_produced)

	var food_consumed: float = report["consumed"].get(ResourceTypes.ResourceType.FOOD, 0.0)
	_assert(food_consumed > 0.0, "Villagers consumed food: %.2f" % food_consumed)

	print("  Resources after tick: %s" % resources.get_all_resources_summary())

func test_combat_resolver() -> void:
	_section("Combat Resolver")

	var attackers: Array[SquadTypes.SquadData] = [
		SquadTypes.SquadData.new(&"atk_1", &"lt_1", 20),
		SquadTypes.SquadData.new(&"atk_2", &"lt_1", 15),
	]
	var defenders: Array[SquadTypes.SquadData] = [
		SquadTypes.SquadData.new(&"def_1", &"lt_2", 10),
	]

	var attacker_wins: int = 0
	var total_runs: int = 20
	for run: int in range(total_runs):
		var result: CombatResult = CombatResolver.resolve_combat(attackers, defenders)
		if result.attacker_won:
			attacker_wins += 1

	_assert(attacker_wins > 5, "Attackers (35 units) win at least sometimes against defenders (10)")
	_assert(attacker_wins < total_runs, "Defenders sometimes win (RNG)")
	print("  Attacker won %d/%d battles (35 vs 10 units)" % [attacker_wins, total_runs])

	var result: CombatResult = CombatResolver.resolve_combat(attackers, defenders)
	print("  Sample result: %s" % result.to_string_summary())

func test_full_game_loop() -> void:
	_section("Full Game Loop (10 ticks)")
	resources.reset()
	villagers.reset()
	lots.reset()
	decrees.reset()
	clans.reset()
	army.reset()

	resources.add_resource(ResourceTypes.ResourceType.FOOD, 200.0)
	resources.add_resource(ResourceTypes.ResourceType.SCRAP, 50.0)

	var player_clan: ClanTypes.ClanData = ClanTypes.ClanData.new(&"chosen", "The Chosen")
	clans.register_clan(player_clan)

	for i: int in range(5):
		var v: VillagerTypes.VillagerData = VillagerTypes.VillagerData.new(
			StringName("v_%d" % i), "Survivor %d" % i
		)
		PersonalityData.randomize_traits(v)
		v.clan_id = &"chosen"
		villagers.register_villager(v)
		clans.add_member_to_clan(v.villager_id, &"chosen")

	var home_lot: LotTypes.LotData = LotTypes.LotData.new(&"home_base", Vector2.ZERO)
	home_lot.owning_clan_id = &"chosen"
	lots.register_lot(home_lot)

	var farm: BuildingTypes.BuildingData = BuildingTypes.BuildingData.new(&"main_farm", BuildingTypes.BuildingType.FARM)
	farm.is_constructed = true
	farm.assigned_worker_ids = [&"v_0", &"v_1"]
	farm.lot_id = &"home_base"
	economy.register_building(farm)
	lots.add_building_to_lot(&"main_farm", &"home_base")

	var lt: LieutenantAI = LieutenantAI.new(&"commander", 0.7, 0.8)
	decrees.register_lieutenant(lt)

	var squad: SquadTypes.SquadData = SquadTypes.SquadData.new(&"squad_alpha", &"commander", 15)
	army.register_squad(squad)

	var decree: DecreeTypes.Decree = DecreeTypes.Decree.new(
		DecreeTypes.DecreeType.GATHER, &"home_base", 5
	)
	decrees.issue_decree(decree)

	print("  Initial: %s" % resources.get_all_resources_summary())
	for tick: int in range(10):
		villagers.tick_villagers(1.0)
		economy.tick_economy(1.0, resources, villagers)
		decrees.tick_decrees(1.0)

	print("  After 10 ticks: %s" % resources.get_all_resources_summary())

	_assert(resources.get_resource(ResourceTypes.ResourceType.FOOD) > 0.0,
		"Still have food after 10 ticks")

	var v0: VillagerTypes.VillagerData = villagers.get_villager(&"v_0")
	_assert(v0.morale > 0.0 and v0.morale <= 100.0,
		"Villager morale is in valid range: %.1f" % v0.morale)

	_assert(army.get_total_army_power() == 15.0,
		"Army power is 15.0 (1 squad of 15)")

	var remaining_decrees: Array = decrees.get_active_decrees()
	print("  Remaining decrees: %d" % remaining_decrees.size())
	print(villagers.get_summary())
	print(army.get_summary())

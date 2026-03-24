class_name RelationshipGraph

## A single directed relationship edge between two villagers.
class RelationshipEdge:
	var target_villager_id: StringName
	var affinity: float  # -100 to 100
	var trust: float     # 0 to 100

	func _init(p_target: StringName = &"", p_affinity: float = 0.0, p_trust: float = 50.0) -> void:
		target_villager_id = p_target
		affinity = p_affinity
		trust = p_trust

## Adjacency map: source_id -> Array[RelationshipEdge]
var _adjacency: Dictionary = {}

## Add or update a relationship between two villagers.
func set_relationship(source_id: StringName, target_id: StringName, affinity: float, trust: float) -> void:
	if source_id not in _adjacency:
		_adjacency[source_id] = []
	var edges: Array = _adjacency[source_id]
	for edge: RelationshipEdge in edges:
		if edge.target_villager_id == target_id:
			edge.affinity = clampf(affinity, -100.0, 100.0)
			edge.trust = clampf(trust, 0.0, 100.0)
			return
	edges.append(RelationshipEdge.new(target_id, clampf(affinity, -100.0, 100.0), clampf(trust, 0.0, 100.0)))

## Get a relationship edge. Returns null if none exists.
func get_relationship(source_id: StringName, target_id: StringName) -> RelationshipEdge:
	if source_id not in _adjacency:
		return null
	for edge: RelationshipEdge in _adjacency[source_id]:
		if edge.target_villager_id == target_id:
			return edge
	return null

## Get all relationships for a source villager.
func get_relationships_for(source_id: StringName) -> Array:
	if source_id not in _adjacency:
		return []
	return _adjacency[source_id]

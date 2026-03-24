extends Node

## GameInstance-equivalent subsystem managing all resources.
## Registered as autoload "Resources" in project.godot.

signal resource_changed(type: ResourceTypes.ResourceType, new_amount: float)

var _resources: Dictionary = {}

func _ready() -> void:
	reset()

## Reset all resources to zero. Called on init and optionally on scene change.
func reset() -> void:
	_resources.clear()
	for type_val: int in ResourceTypes.ResourceType.values():
		_resources[type_val] = 0.0

func get_resource(type: ResourceTypes.ResourceType) -> float:
	return _resources.get(type, 0.0)

func add_resource(type: ResourceTypes.ResourceType, amount: float) -> void:
	_resources[type] = _resources.get(type, 0.0) + amount
	resource_changed.emit(type, _resources[type])

func consume_resource(type: ResourceTypes.ResourceType, amount: float) -> bool:
	var current: float = _resources.get(type, 0.0)
	if current < amount:
		return false
	_resources[type] = current - amount
	resource_changed.emit(type, _resources[type])
	return true

func can_afford(costs: Array) -> bool:
	for cost: ResourceTypes.ResourceAmount in costs:
		if get_resource(cost.type) < cost.amount:
			return false
	return true

func get_all_resources_summary() -> String:
	var parts: Array[String] = []
	for type_val: int in ResourceTypes.ResourceType.values():
		var res_name: String = ResourceTypes.ResourceType.keys()[type_val]
		parts.append("%s=%.1f" % [res_name, _resources.get(type_val, 0.0)])
	return ", ".join(parts)

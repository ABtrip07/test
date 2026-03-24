class_name ResourceTypes

## Core resource types in the game economy.
enum ResourceType {
	SCRAP,
	FUEL,
	REAGENTS,
	DATA,
	FOOD,
	PEOPLE,
}

## A quantity of a specific resource.
class ResourceAmount:
	var type: ResourceType
	var amount: float

	func _init(p_type: ResourceType = ResourceType.SCRAP, p_amount: float = 0.0) -> void:
		type = p_type
		amount = p_amount

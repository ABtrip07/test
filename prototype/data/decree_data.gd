class_name DecreeTypes

## Types of decrees the God-King can issue.
enum DecreeType {
	BUILD,
	GATHER,
	RESEARCH,
	DEFEND,
	ATTACK,
	RECRUIT,
	CELEBRATE,
	EXILE,
}

## A decree issued by the God-King, interpreted by lieutenants.
class Decree:
	var type: DecreeType
	var target_id: StringName
	var priority: int
	var time_issued: float
	## Progress from 0.0 to 1.0. Decree completes at 1.0.
	var progress: float
	## The lieutenant assigned to execute this decree.
	var assigned_lieutenant_id: StringName

	func _init(
		p_type: DecreeType = DecreeType.BUILD,
		p_target: StringName = &"",
		p_priority: int = 0,
		p_time: float = 0.0
	) -> void:
		type = p_type
		target_id = p_target
		priority = p_priority
		time_issued = p_time
		progress = 0.0
		assigned_lieutenant_id = &""

	func is_complete() -> bool:
		return progress >= 1.0

	func to_string_summary() -> String:
		return "Decree(%s target=%s priority=%d progress=%.0f%%)" % [
			DecreeType.keys()[type], target_id, priority, progress * 100.0
		]

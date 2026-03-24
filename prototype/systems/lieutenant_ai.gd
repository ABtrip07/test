class_name LieutenantAI

## AI for lieutenants that interpret and execute God-King decrees.
## RefCounted (not a Node) -- pure logic, maps to UE5 UActorComponent.

var lieutenant_id: StringName
var competence: float  # 0-1, affects execution speed
var loyalty: float     # 0-1, affects chance of defection/sabotage

var _assigned_decrees: Array[DecreeTypes.Decree] = []

func _init(p_id: StringName = &"", p_competence: float = 0.5, p_loyalty: float = 0.5) -> void:
	lieutenant_id = p_id
	competence = p_competence
	loyalty = p_loyalty

## Assign a decree to this lieutenant.
func assign_decree(decree: DecreeTypes.Decree) -> void:
	_assigned_decrees.append(decree)

## Get how suitable this lieutenant is for a decree (higher = better).
func get_suitability_for(decree: DecreeTypes.Decree) -> float:
	var load_penalty: float = _assigned_decrees.size() * 0.2
	var type_bonus: float = 0.0
	match decree.type:
		DecreeTypes.DecreeType.ATTACK, DecreeTypes.DecreeType.DEFEND:
			type_bonus = competence * 0.3
		DecreeTypes.DecreeType.BUILD, DecreeTypes.DecreeType.GATHER:
			type_bonus = loyalty * 0.2
		_:
			type_bonus = 0.1
	return maxf(0.0, competence + type_bonus - load_penalty)

## Tick AI: progress on assigned decrees.
func tick_ai(delta_time: float) -> void:
	for decree: DecreeTypes.Decree in _assigned_decrees:
		if not decree.is_complete():
			_progress_decree(decree, delta_time)
	# Remove completed decrees from local list
	_assigned_decrees = _assigned_decrees.filter(
		func(d: DecreeTypes.Decree) -> bool: return not d.is_complete()
	)

func _progress_decree(decree: DecreeTypes.Decree, dt: float) -> void:
	var rate: float = (competence * 0.7 + loyalty * 0.3) * 0.1
	decree.progress = minf(1.0, decree.progress + rate * dt)

func get_active_decree_count() -> int:
	return _assigned_decrees.size()

func to_string_summary() -> String:
	return "Lieutenant(%s comp=%.2f loyal=%.2f decrees=%d)" % [
		lieutenant_id, competence, loyalty, _assigned_decrees.size()
	]

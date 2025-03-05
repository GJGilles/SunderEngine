extends TeamData

class_name BaseEnemyTeamData

@export var party: TeamData

var choice_queue: Array[Callable] = []

signal action_selected(action: BaseActionData, source: BaseUnitData, targets: Array[BaseUnitData])
signal round_done()

func choose_actions():
	pass
	
func next_action():
	while choice_queue.size() > 0:
		var choice: Callable = choice_queue.pop_front()
		if choice.call():
			return
	
	round_done.emit()

func get_lowest_players(defense: COMBAT.DEFENSE_TYPE, include_stunned: bool = false) -> Array[BaseUnitData]:
	var sorted: Array[BaseUnitData] = party.units.values() 
	sorted.sort_custom(func(a, b): return a.get_curr_stat(defense) < b.get_curr_stat(defense))
	if !include_stunned:
		var filtered: Array[BaseUnitData] = sorted.filter(func(u): return !u.is_stunned())
		if filtered.size() > 0:
			sorted = filtered
			
	return sorted
	
func get_highest_players(defense: COMBAT.DEFENSE_TYPE, include_stunned: bool = false) -> Array[BaseUnitData]:
	var sorted: Array[BaseUnitData] = party.units.values() 
	sorted.sort_custom(func(a, b): return a.get_curr_stat(defense) > b.get_curr_stat(defense))
	if !include_stunned:
		var filtered: Array[BaseUnitData] = sorted.filter(func(u): return !u.is_stunned())
		if filtered.size() > 0:
			sorted = filtered
			
	return sorted

func try_do_action(action: BaseActionData, source: BaseUnitData, main_target: BaseUnitData) -> bool:
	if source.can_do_action(action):
		var targets: Array[BaseUnitData] = party.get_unit_targets(main_target, action.area_type)
		action_selected.emit(action, source, targets)
		return true
	else:
		return false

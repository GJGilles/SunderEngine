extends Node

class_name TurnTrackData

var turns: Array[TurnData] = []

signal added_turn(turn: TurnData)
signal removed_turn(idx: int)
	
func next_turn() -> TurnData:
	var curr_turn: TurnData = turns.pop_front()
	removed_turn.emit(0)
	return curr_turn
	
func add_turn(action: BaseActionData, source: BaseUnitData, targets: Array[BaseUnitData]):
	var turn: TurnData = TurnData.new()
	add_child(turn)
	turn.action = action
	turn.source = source
	turn.targets.assign(targets)
	
	turns.append(turn)
	added_turn.emit(turn)

func remove_unit(unit: BaseUnitData):
	var idx: int = turns.find_custom(func(t): return t.source == unit)
	while idx >= 0:
		var turn: TurnData = turns[idx]
		
		turns.remove_at(idx)
		removed_turn.emit(idx)
		idx = turns.find_custom(func(t): return t.source == unit)

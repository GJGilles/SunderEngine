extends Node

class_name TurnTrackData

var turns: Array[TurnData]
var curr_turn: TurnData

signal inserted_turn(idx: int, turn: TurnData)
signal removed_turn(idx: int)
signal updated_turn(idx: int, time: int)

func set_values(units: Array[BaseUnitData]):
	turns = []
	
	for u in units:
		insert_empty_turn(u)
	
func next_turn() -> TurnData:
	curr_turn = turns[0]
	
	var time_passed: int = curr_turn.time
	if time_passed != 0:
		for idx in turns.size():
			turns[idx].time -= time_passed
			updated_turn.emit(idx, turns[idx].time)
		
	turns.pop_front()
	removed_turn.emit(0)
	return curr_turn
	
func insert_turn(turn: TurnData):
	var idx: int = 0
	for t in turns:
		if t.time > turn.time:
			break
		idx += 1
		
	turns.insert(idx, turn)
	inserted_turn.emit(idx, turn)
	
func insert_empty_turn(unit: BaseUnitData):
		var t: TurnData = TurnData.new()
		add_child(t)
		
		t.time = unit.get_speed()
		t.source = unit
		
		insert_turn(t)

func remove_unit(unit: BaseUnitData) -> TurnData:
	var idx: int = turns.find_custom(func(t): return t.source == unit)
	var turn: TurnData = turns[idx]
	
	turns.remove_at(idx)
	removed_turn.emit(idx)
	
	return turn

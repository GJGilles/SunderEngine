extends Node

class_name TurnData

var time: int

var action: BaseActionData

var source: BaseUnitData
var targets: Array[BaseUnitData]

func clone() -> TurnData:
	var new_turn: TurnData = TurnData.new()
	
	new_turn.time = time
	new_turn.action = action
	new_turn.source = source
	new_turn.targets.assign(targets)
	
	return new_turn

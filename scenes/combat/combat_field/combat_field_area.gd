extends Control

class_name CombatFieldArea

@onready var front_top: CombatFieldUnit = $FrontRow/FrontTop
@onready var front_bot: CombatFieldUnit = $FrontRow/FrontBot
@onready var back_top: CombatFieldUnit = $BackRow/BackTop
@onready var back_bot: CombatFieldUnit = $BackRow/BackBot

var square_dict: Dictionary[TeamData.POSITION, CombatFieldUnit]

var target_total: int = 0
var target_list: Array[BaseUnitData] = []

signal targets_selected(targets: Array[BaseUnitData])
signal targets_changed(targets: Array[BaseUnitData])
signal on_focused(unit: BaseUnitData)
signal on_unfocused(unit: BaseUnitData)

func _ready():
	square_dict = {
			TeamData.POSITION.FRONT_TOP: front_top,
			TeamData.POSITION.FRONT_BOT: front_bot,
			
			TeamData.POSITION.BACK_TOP: back_top,
			TeamData.POSITION.BACK_BOT: back_bot
		}
		
func set_values(team: TeamData):
	for key in square_dict.keys():
		if team.characters.has(key):
			var unit: BaseUnitData = team.characters[key]
			square_dict[key].set_values(unit)
			square_dict[key].on_selected.connect(func(): add_target(key))
			square_dict[key].on_focused.connect(func(): on_focused.emit(unit))
			square_dict[key].on_unfocused.connect(func(): on_unfocused.emit(unit))
		else:
			square_dict[key].set_empty()
			
func get_value(pos: TeamData.POSITION) -> CombatFieldUnit:
	return square_dict[pos]
	
func get_targets(num: int):
	target_total = num
	target_list = []
	
func add_target(pos: TeamData.POSITION):
	var unit: BaseUnitData = square_dict[pos].base_unit
	
	target_list.append(unit)
	if target_list.size() == target_total:
		targets_selected.emit(target_list)
	elif target_list.size() < target_total:
		square_dict[pos].add_target_tick()	
		targets_changed.emit(target_list)

extends Control

class_name CombatFieldArea

@onready var front_top: CombatFieldUnit = $FrontRow/FrontTop
@onready var front_bot: CombatFieldUnit = $FrontRow/FrontBot
@onready var back_top: CombatFieldUnit = $BackRow/BackTop
@onready var back_bot: CombatFieldUnit = $BackRow/BackBot

var square_dict: Dictionary[TeamData.POSITION, CombatFieldUnit]

var is_targeting: bool = false
var target_area: COMBAT.AREA_TYPE

signal targets_selected(targets: Array[BaseUnitData])
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
		if team.units.has(key):
			var unit: BaseUnitData = team.units[key]
			square_dict[key].set_values(unit)
			square_dict[key].on_selected.connect(func(_u): add_target(key))
			square_dict[key].on_focused.connect(func(): on_focused.emit(unit))
			square_dict[key].on_unfocused.connect(func(): on_unfocused.emit(unit))
		else:
			square_dict[key].set_empty()

func set_selectable(selectable: bool):
	for pos in square_dict:
		if square_dict[pos].base_unit != null:
			square_dict[pos].set_selectable(selectable)
		
func get_value(pos: TeamData.POSITION) -> CombatFieldUnit:
	return square_dict[pos]
	
func get_targets(area: COMBAT.AREA_TYPE):
	is_targeting = true
	target_area = area
	
func cancel_targeting():
	is_targeting = false
	
func add_target(pos: TeamData.POSITION):
	if is_targeting:
		var targets: Array[BaseUnitData] 
		targets.append(square_dict[pos].base_unit)
		targets_selected.emit(targets)
		is_targeting = false

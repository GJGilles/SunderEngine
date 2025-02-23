extends Control

class_name CombatFieldArea

@onready var front_top: CombatFieldUnit = $FrontRow/FrontTop
@onready var front_bot: CombatFieldUnit = $FrontRow/FrontBot
@onready var back_top: CombatFieldUnit = $BackRow/BackTop
@onready var back_bot: CombatFieldUnit = $BackRow/BackBot

var square_dict: Dictionary[TeamData.POSITION, CombatFieldUnit]

var target_total: int = 0
var target_list: Array[TeamData.POSITION] = []

signal targets_selected(targets: Array[TeamData.POSITION])

func _ready():
	square_dict = {
			TeamData.POSITION.FRONT_TOP: front_top,
			TeamData.POSITION.FRONT_BOT: front_bot,
			
			TeamData.POSITION.BACK_TOP: back_top,
			TeamData.POSITION.BACK_BOT: back_bot
		}
		
func _on_front_top_selected() -> void:
	add_target(TeamData.POSITION.FRONT_TOP)

func _on_front_bot_selected() -> void:
	add_target(TeamData.POSITION.FRONT_BOT)

func _on_back_top_selected() -> void:
	add_target(TeamData.POSITION.BACK_TOP)

func _on_back_bot_selected() -> void:
	add_target(TeamData.POSITION.BACK_BOT)

func set_values(team: TeamData):
	for key in square_dict.keys():
		if team.characters.has(key):
			square_dict[key].set_values(team.characters[key])
		else:
			square_dict[key].set_empty()	
	
func get_targets(num: int):
	target_total = num
	target_list = []
	set_selectable()
	
func add_target(pos: TeamData.POSITION):
	target_list.append(pos)
	if target_list.size() == target_total:
		targets_selected.emit(target_list)
		set_unselectable()
	else:
		square_dict[pos].add_target_tick()
			
func set_selectable():
	for key in square_dict.keys():
		square_dict[key].set_selectable()
	
func set_unselectable():
	for key in square_dict.keys():
		square_dict[key].set_unselectable()
		set_target_ticks(key, 0)
		
func set_target_ticks(pos: TeamData.POSITION, num: int):
	square_dict[pos].set_target_ticks(num)

func attack_unit(pos: TeamData.POSITION):
	return square_dict[pos].play_attack()
	
func damage_unit(pos: TeamData.POSITION):
	return square_dict[pos].play_damaged()
	

extends Control

class_name CombatFieldArea

@onready var front_top: CombatFieldUnit = $FrontRow/FrontTop
@onready var front_bot: CombatFieldUnit = $FrontRow/FrontBot
@onready var back_top: CombatFieldUnit = $BackRow/BackTop
@onready var back_bot: CombatFieldUnit = $BackRow/BackBot

var square_dict: Dictionary[TeamData.POSITION, CombatFieldUnit]

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
			square_dict[key].set_values(team.characters[key])
		else:
			square_dict[key].set_empty()	

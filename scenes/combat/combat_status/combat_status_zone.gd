extends Control

class_name CombatStatusZone

@onready var top_left: CombatStatusSquare = $TopLeft
@onready var top_right: CombatStatusSquare = $TopRight
@onready var bot_left: CombatStatusSquare = $BotLeft
@onready var bot_right: CombatStatusSquare = $BotRight

@export var is_flip: bool = false
var square_dict: Dictionary[TeamData.POSITION, CombatStatusSquare]

func _ready():
	if is_flip:		
		square_dict = {
			TeamData.POSITION.FRONT_TOP: top_left,
			TeamData.POSITION.FRONT_BOT: bot_left,
			
			TeamData.POSITION.BACK_TOP: top_right,
			TeamData.POSITION.BACK_BOT: bot_right
		}
	else:
		square_dict = {
			TeamData.POSITION.FRONT_TOP: top_right,
			TeamData.POSITION.FRONT_BOT: bot_right,
			
			TeamData.POSITION.BACK_TOP: top_left,
			TeamData.POSITION.BACK_BOT: bot_left
		}

func set_values(team: TeamData):
	for key in square_dict.keys():
		if team.units.has(key):
			square_dict[key].set_values(team.units[key])
		else:
			square_dict[key].set_empty()	
		
func get_value(pos: TeamData.POSITION) -> CombatStatusSquare:
	return square_dict[pos]

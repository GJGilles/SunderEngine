extends Control

class_name CombatStatusZone

@onready var top_left: CombatStatusSquareController = $TopLeft
@onready var top_mid: CombatStatusSquareController = $TopMid
@onready var top_right: CombatStatusSquareController = $TopRight
@onready var bot_left: CombatStatusSquareController = $BotLeft
@onready var bot_mid: CombatStatusSquareController = $BotMid
@onready var bot_right: CombatStatusSquareController = $BotRight

var square_dict: Dictionary[TeamData.POSITION, CombatStatusSquareController]

func _ready():
	square_dict = {
		TeamData.POSITION.FRONT_TOP: top_left,
		TeamData.POSITION.FRONT_MID: top_mid,
		TeamData.POSITION.FRONT_BOT: top_right,
		
		TeamData.POSITION.BACK_TOP: bot_left,
		TeamData.POSITION.BACK_MID: bot_mid,
		TeamData.POSITION.BACK_BOT: bot_right
	}

func set_values(team: TeamData):
	for key in square_dict.keys():
		if team.characters.has(key):
			square_dict[key].set_values(team.characters[key])
		else:
			square_dict[key].set_empty()	
		
func update_unit(pos: TeamData.POSITION, amount: int, defense: COMBAT.DEFENSE_TYPE):
	var square: CombatStatusSquareController = square_dict[pos]
	
	match defense:
		COMBAT.DEFENSE_TYPE.ARMOR:
			return square.update_armor(amount)
		COMBAT.DEFENSE_TYPE.MANA:
			return square.update_mana(amount)
		COMBAT.DEFENSE_TYPE.HEALTH:
			return square.update_health(amount)
	

extends Node

class_name BaseUnitData

@export var portrait: Texture2D
@export var sprite: Texture2D

var curr_health: int
var curr_armor: int
var curr_mana: int

func is_ranged() -> bool:
	return false

func get_portrait() -> Texture2D:
	return portrait

func get_speed() -> int:
	return 0

func get_max_health() -> int:
	return 0
	
func get_max_armor() -> int:
	return 0
	
func get_max_mana() -> int:
	return 0
	
func reset_stats():
	curr_health = get_max_health()
	curr_armor = get_max_armor()
	curr_mana = get_max_mana()
	
func get_curr_stat(type: COMBAT.DEFENSE_TYPE):
	match type:
		COMBAT.DEFENSE_TYPE.ARMOR:
			return curr_armor
		COMBAT.DEFENSE_TYPE.MANA:
			return curr_mana
		COMBAT.DEFENSE_TYPE.HEALTH:
			return curr_health

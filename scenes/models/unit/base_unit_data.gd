extends Node

class_name BaseUnitData

@export var portrait: Texture2D

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

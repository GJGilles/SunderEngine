extends Node

class_name CharacterData

@export var portrait: ViewportTexture

var current_class: ClassData

var curr_health: int
var curr_armor: int
var curr_mana: int

func get_portrait():
	return portrait

func get_max_health():
	return current_class.base_health
	
func get_max_armor():
	return current_class.base_armor
	
func get_max_mana():
	return current_class.base_mana

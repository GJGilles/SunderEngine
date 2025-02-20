extends Node

class_name ClassData

enum RANGE_TYPE {
	MELEE,
	RANGED
}

@export var base_speed: int

@export var base_health: int
@export var base_armor: int
@export var base_mana: int
@export var range_type: RANGE_TYPE

@export var actions: Array[BaseActionData] = []

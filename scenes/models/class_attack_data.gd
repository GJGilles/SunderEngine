extends Node

class_name ClassAttackData

enum ATTACK_TYPE {
	FIRE,
	WIND,
	ENERGY,
	DARK,
	
	PIERCE,
	SLASH,
	BASH,
	DIVINE,
	
	HEAL,
	POISON,
	BLOCK,
	SPEED
}


@export var type: ATTACK_TYPE
@export var hits: int
@export var damage: int
@export var mana_cost: int
@export var time_cost: int


extends Node

class_name TeamData

enum POSITION {
	FRONT_TOP,
	FRONT_BOT,
	
	BACK_TOP,
	BACK_BOT
}

@export var characters: Dictionary[POSITION, BaseUnitData]

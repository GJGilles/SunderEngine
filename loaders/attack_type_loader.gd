extends Node

const OUTLINE_GOLD = preload("res://scenes/combat/resource/combat_outline_gold.tres")
const OUTLINE_WHITE = preload("res://scenes/combat/resource/combat_outline_white.tres")
const OUTLINE_GREEN = preload("res://scenes/combat/resource/combat_outline_green.tres")
const OUTLINE_RED = preload("res://scenes/combat/resource/combat_outline_red.tres")
const OUTLINE_BLUE = preload("res://scenes/combat/resource/combat_outline_blue.tres")

enum ATTACK_TYPE {
	PHYSICAL,
	MAGIC
}

enum DEFENSE_TYPE {
	ARMOR,
	MANA,
	HEALTH
}

enum STATUS_TYPE {
	MEND,
	BLESS,
	HASTE,
	
	CORRODE,
	CURSE,
	SLOW
}

enum REACT_TYPE {	
	BLOCK,
	EVADE,
	PARRY,
	
	WEAKENED,
	PINNED,
	FUMBLE
}

enum TARGET_TYPE {
	SELF,
	ENEMY,
	ALLY
}

enum AREA_TYPE {
	SINGLE,
	ROW,
	COLUMN
}

enum OUTLINE_COLOR {
	GOLD, # Preview Source
	WHITE, # Preview Target
	GREEN, # Current Turn
	RED, # Enemy Target
	BLUE # Player Target
}

@export var attack_phys: Texture2D
@export var attack_magic: Texture2D

@export var defense_armor: Texture2D
@export var defense_mana: Texture2D
@export var defense_health: Texture2D

@export var status_mend: Texture2D
@export var status_corrode: Texture2D
@export var status_bless: Texture2D
@export var status_curse: Texture2D

@export var react_block: Texture2D
@export var react_evade: Texture2D

func get_outline_resource(color: OUTLINE_COLOR):
	match color:
		OUTLINE_COLOR.GOLD:
			return OUTLINE_GOLD
		OUTLINE_COLOR.WHITE:
			return OUTLINE_WHITE
		OUTLINE_COLOR.GREEN:
			return OUTLINE_GREEN
		OUTLINE_COLOR.RED:
			return OUTLINE_RED
		OUTLINE_COLOR.BLUE:
			return OUTLINE_BLUE

func get_opposite_status(type: STATUS_TYPE):
	match type:
		STATUS_TYPE.MEND:
			return STATUS_TYPE.CORRODE
		STATUS_TYPE.CORRODE:
			return STATUS_TYPE.MEND
		STATUS_TYPE.BLESS:
			return STATUS_TYPE.CURSE
		STATUS_TYPE.CURSE:
			return STATUS_TYPE.BLESS

func get_attack_icon(type: ATTACK_TYPE):
	match type:
		ATTACK_TYPE.PHYSICAL:
			return attack_phys
		ATTACK_TYPE.MAGIC:
			return attack_magic
	
func get_defense_icon(type: DEFENSE_TYPE):
	match type:
		DEFENSE_TYPE.ARMOR:
			return defense_armor
		DEFENSE_TYPE.MANA:
			return defense_mana
		DEFENSE_TYPE.HEALTH:
			return defense_health
	
func get_status_icon(type: STATUS_TYPE):
	match type:
		STATUS_TYPE.MEND:
			return status_mend
		STATUS_TYPE.CORRODE:
			return status_corrode
		STATUS_TYPE.BLESS:
			return status_bless
		STATUS_TYPE.CURSE:
			return status_curse
	
func get_react_icon(type: REACT_TYPE):
	match type:
		REACT_TYPE.BLOCK:
			return react_block
		REACT_TYPE.EVADE:
			return react_evade

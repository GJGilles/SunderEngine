extends Node

enum ATTACK_TYPE {
	PHYSICAL,
	MAGIC,
	STATUS
}

enum DEFENSE_TYPE {
	ARMOR,
	MANA,
	HEALTH
}

enum STATUS_TYPE {
	MEND,
	CORRODE,
	BLESS,
	CURSE
}

enum REACT_TYPE {	
	BLOCK,
	EVADE
}

enum TARGET_TYPE {
	SELF,
	ENEMY,
	ALLY
}

@export var attack_phys: Texture2D
@export var attack_magic: Texture2D
@export var attack_status: Texture2D

@export var defense_armor: Texture2D
@export var defense_mana: Texture2D
@export var defense_health: Texture2D

@export var status_mend: Texture2D
@export var status_corrode: Texture2D
@export var status_bless: Texture2D
@export var status_curse: Texture2D

@export var react_block: Texture2D
@export var react_evade: Texture2D

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
		ATTACK_TYPE.STATUS:
			return attack_status
	
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

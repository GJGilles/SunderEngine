extends Node

enum TYPE {
	FIRE,
	WIND,
	ENERGY,
	DARK,
	
	PIERCE,
	SLASH,
	BASH,
	DIVINE,
	
#	STATUS EFFECTS
	MEND,
	CORRODE,
	BLESS,
	CURSE
}

enum STATUS {
	MEND,
	CORRODE,
	BLESS,
	CURSE,
	
	BLOCKED,
	EVADE
}

#Switch to element / damage type enums to be more functional focused


@export var icon_fire: Texture
@export var icon_wind: Texture
@export var icon_energy: Texture
@export var icon_dark: Texture
@export var icon_pierce: Texture
@export var icon_slash: Texture
@export var icon_bash: Texture
@export var icon_divine: Texture
@export var icon_heal: Texture
@export var icon_poison: Texture
@export var icon_block: Texture
@export var icon_speed: Texture

# Might have to move to autoload if we need resources
func get_type_icon(type: TYPE):
	match type:
		TYPE.FIRE:
			return icon_fire
		TYPE.WIND:
			return icon_wind
		TYPE.ENERGY:
			return icon_energy
		TYPE.DARK:
			return icon_dark
		TYPE.PIERCE:
			return icon_pierce
		TYPE.SLASH:
			return icon_slash
		TYPE.BASH:
			return icon_bash
		TYPE.DIVINE:
			return icon_divine
		TYPE.MEND:
			return icon_heal
		TYPE.CORRODE:
			return icon_poison
		TYPE.BLESS:
			return icon_block
		TYPE.CURSE:
			return icon_fire

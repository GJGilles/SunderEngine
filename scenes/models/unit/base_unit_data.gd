extends Node

class_name BaseUnitData

@export var portrait: Texture2D
@export var combat_sprite: SpriteFrames

var curr_health: int
var curr_armor: int
var curr_mana: int

var curr_status: Dictionary[COMBAT.STATUS_TYPE, int] = {}

var curr_block: ReactActionData
var curr_evade_count: int = 0

#region Signals
signal unit_action(action: BaseActionData)

signal attack_evaded()
signal attack_blocked()

signal unit_damaged(defense: COMBAT.DEFENSE_TYPE)
signal unit_stunned()
signal unit_fainted()

signal unit_healed(defense: COMBAT.DEFENSE_TYPE)
signal unit_revived()

signal status_changed(type: COMBAT.STATUS_TYPE, value: int)
signal react_changed(type: COMBAT.REACT_TYPE, value: int)
#endregion

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
			
func do_action(action: BaseActionData):
	unit_action.emit(action)
			
func apply_damage(damage: int, attack: COMBAT.ATTACK_TYPE, defense: COMBAT.DEFENSE_TYPE):
	if curr_evade_count > 0:
		curr_evade_count -= 1
		attack_evaded.emit()
		return
	
	if curr_block != null:
		#if curr_block.source != self:
			#return curr_block.source.apply_damage(damage, attack, defense)
		#else:
			damage -= curr_block.value
			if damage <= 0:
				attack_blocked.emit()
				return
				
	if defense == COMBAT.DEFENSE_TYPE.HEALTH:
		if attack == COMBAT.ATTACK_TYPE.PHYSICAL:
			damage = floori(damage * (1 - curr_armor / 100.0))
		elif attack == COMBAT.ATTACK_TYPE.MAGIC:
			damage = floori(damage * (1 - curr_mana / 100.0))
		
		if curr_health > 0 and 0 >= (curr_health - damage):
			curr_health = 0
			unit_stunned.emit()
		elif curr_health > -100 and -100 >= (curr_health - damage):
			curr_health = -100
			unit_fainted.emit()
		else:
			curr_health -= damage
			unit_damaged.emit(COMBAT.DEFENSE_TYPE.HEALTH)
	
	elif defense == COMBAT.DEFENSE_TYPE.ARMOR:
		damage = mini(damage, 100 + curr_armor)
		curr_armor -= damage
		unit_damaged.emit(COMBAT.DEFENSE_TYPE.ARMOR)
	
	elif defense == COMBAT.DEFENSE_TYPE.MANA:
		damage = mini(damage, 100 + curr_mana)
		curr_mana -= damage
		unit_damaged.emit(COMBAT.DEFENSE_TYPE.MANA)
		
func apply_status(action: StatusActionData):
	var opp = COMBAT.get_opposite_status(action.status)
	if curr_status.has(opp):
		curr_status.erase(opp)
		status_changed.emit(opp, 0)
		return
	
	var value: int = action.value
	if curr_status.has(action.status):
		tick_status(action.status)
		value = max(value, action.value)
	
	curr_status[action.status] = value
	status_changed.emit(action.status, value)	
	
func tick_all_status():
	for key in curr_status.keys():
		tick_status(key)
	
func tick_status(status: COMBAT.STATUS_TYPE):
	var value: int = curr_status[status]
	
	match status:
		COMBAT.STATUS_TYPE.MEND:
			if curr_armor < get_max_armor():
				var heal = min(value, get_max_armor() - curr_armor)
				curr_armor += heal
				value -= heal
				unit_healed.emit(COMBAT.DEFENSE_TYPE.ARMOR)
				
			if value > 0 and curr_health < get_max_health():
				var heal = min(value, get_max_health() - curr_health)
				if curr_health <= 0 and 0 < curr_health + heal:
					curr_health += heal
					unit_revived.emit()
				else:
					curr_health += heal
					unit_healed.emit(COMBAT.DEFENSE_TYPE.HEALTH)
		
		COMBAT.STATUS_TYPE.CORRODE:
			if curr_armor > 0:
				var damage = min(value, curr_armor)
				curr_armor -= damage
				value -= damage
				unit_damaged.emit(COMBAT.DEFENSE_TYPE.ARMOR)
				
			if value > 0 and curr_health > 1:
				var damage = min(value, curr_health - 1)
				curr_health -= damage
				unit_damaged.emit(COMBAT.DEFENSE_TYPE.HEALTH)
		
		COMBAT.STATUS_TYPE.BLESS:
			if curr_health < get_max_health():
				var heal = min(value, get_max_health() - curr_health)
				if curr_health <= 0 and 0 < curr_health + heal:
					curr_health += heal
					unit_revived.emit()
				else:
					curr_health += heal
					unit_healed.emit(COMBAT.DEFENSE_TYPE.HEALTH)
				value -= heal
			
			if value > 0 and  curr_mana < get_max_mana():
				var heal = min(value, get_max_mana() - curr_mana)
				curr_mana += heal
				unit_healed.emit(COMBAT.DEFENSE_TYPE.MANA)
		
		COMBAT.STATUS_TYPE.CURSE:
			if curr_health > 1:
				var damage = min(value, curr_health - 1)
				curr_health -= damage
				value -= damage
				unit_damaged.emit(COMBAT.DEFENSE_TYPE.HEALTH)
				
			if value > 0 and curr_mana > 0:
				var damage = min(value, curr_mana)
				curr_mana -= damage
				unit_damaged.emit(COMBAT.DEFENSE_TYPE.MANA)
	
func apply_react(action: ReactActionData):
	match action.react:
		COMBAT.REACT_TYPE.BLOCK:
			curr_block = action
		COMBAT.REACT_TYPE.EVADE:
			curr_evade_count = action.value
	react_changed.emit(action.react, action.value)
	
func remove_react(action: ReactActionData):
	match action.react:
		COMBAT.REACT_TYPE.BLOCK:
			curr_block = null
		COMBAT.REACT_TYPE.EVADE:
			curr_evade_count = 0
	react_changed.emit(action.react, 0)

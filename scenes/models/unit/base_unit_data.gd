extends Node

class_name BaseUnitData

@export var portrait: Texture2D
@export var combat_sprite: SpriteFrames

var curr_ap: int
var curr_health: int
var curr_armor: int
var curr_mana: int

var curr_status: Dictionary[COMBAT.STATUS_TYPE, int] = {}

var curr_block: ReactActionData
var curr_evade_count: int = 0

#region Signals
signal action_start(action: BaseActionData, targets: Array[BaseUnitData])
signal action_hit(action: BaseActionData, target: BaseUnitData)
signal action_end(action: BaseActionData, targets: Array[BaseUnitData])

signal attack_evaded()
signal attack_blocked()

signal unit_damaged(defense: COMBAT.DEFENSE_TYPE, amount: int)
signal unit_stunned()
signal unit_fainted()

signal unit_healed(defense: COMBAT.DEFENSE_TYPE, amount: int)
signal unit_revived()

signal ap_changed()
signal status_changed(type: COMBAT.STATUS_TYPE, value: int)
signal react_changed(type: COMBAT.REACT_TYPE, value: int)
#endregion

func clone(include_react: bool = true) -> BaseUnitData:
	var unit: BaseUnitData = duplicate(DuplicateFlags.DUPLICATE_SCRIPTS) 
	unit.curr_health = curr_health
	unit.curr_armor = curr_armor
	unit.curr_mana = curr_mana

	unit.curr_status = curr_status.duplicate(true)

	if include_react:
		unit.curr_block = curr_block
		unit.curr_evade_count = curr_evade_count
		
	return unit

func is_ranged() -> bool:
	return false

func is_stunned() -> bool:
	return curr_health <= 0

func get_portrait() -> Texture2D:
	return portrait

func get_max_ap() -> int:
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
		
func can_do_action(action: BaseActionData) -> bool:
	return action != null and curr_ap >= action.ap_cost and (100 + curr_mana) >= action.mana_cost
			
func pay_action(action: BaseActionData):
	curr_ap -= action.ap_cost
	ap_changed.emit()
	
	if action.mana_cost > 0:
		curr_mana -= action.mana_cost
		unit_damaged.emit(COMBAT.DEFENSE_TYPE.MANA, action.mana_cost)
			
func do_action(action: BaseActionData, targets: Array[BaseUnitData], is_free: bool = false):
	if !is_free:
		pay_action(action)
	
	action_start.emit(action, targets)
	for t in targets:
		for i in action.hits:
			action_hit.emit(action, t)
	
	action_end.emit(action, targets)

func apply_damage(damage: int, attack: COMBAT.ATTACK_TYPE, defense: COMBAT.DEFENSE_TYPE):
	if curr_evade_count > 0:
		curr_evade_count -= 1
		attack_evaded.emit()
		react_changed.emit(COMBAT.REACT_TYPE.EVADE, curr_evade_count)
		return
	
	if curr_block != null:
		damage -= curr_block.value
		attack_blocked.emit()
		
	if damage <= 0:
		unit_damaged.emit(defense, 0)
		return
	
	if attack == COMBAT.ATTACK_TYPE.PHYSICAL:
		damage = floori(damage * (1 - curr_armor / 100.0))
	elif attack == COMBAT.ATTACK_TYPE.MAGIC:
		damage = floori(damage * (1 - curr_mana / 100.0))
				
	if defense == COMBAT.DEFENSE_TYPE.HEALTH:
		if curr_health > 0 and 0 >= (curr_health - damage):
			damage = curr_health
			curr_health = 0
			unit_stunned.emit()
		elif curr_health > -100 and -100 >= (curr_health - damage):
			damage = 100 + curr_health
			curr_health = -100
			unit_fainted.emit()
		else:
			curr_health -= damage
			
		unit_damaged.emit(COMBAT.DEFENSE_TYPE.HEALTH, damage)
		if attack == COMBAT.ATTACK_TYPE.PHYSICAL and curr_armor > 0:
			damage = floori(damage * (curr_armor / 100.0))
			curr_armor -= damage
			unit_damaged.emit(COMBAT.DEFENSE_TYPE.ARMOR, damage)
		elif attack == COMBAT.ATTACK_TYPE.MAGIC and curr_mana > 0:
			damage = floori(damage * (curr_mana / 100.0))
			curr_mana -= damage
			unit_damaged.emit(COMBAT.DEFENSE_TYPE.MANA, damage)
	
	elif defense == COMBAT.DEFENSE_TYPE.ARMOR:
		damage = mini(damage, 100 + curr_armor)
		curr_armor -= damage
		unit_damaged.emit(COMBAT.DEFENSE_TYPE.ARMOR, damage)
	
	elif defense == COMBAT.DEFENSE_TYPE.MANA:
		damage = mini(damage, 100 + curr_mana)
		curr_mana -= damage
		unit_damaged.emit(COMBAT.DEFENSE_TYPE.MANA, damage)
		
func apply_status(action: StatusActionData):
	var opp = COMBAT.get_opposite_status(action.status)
	if curr_status.has(opp):
		curr_status.erase(opp)
		status_changed.emit(opp, 0)
		return
	
	var value: int = action.value
	if curr_status.has(action.status):
		tick_status(action.status, min(value, curr_status[action.status]))
		value = max(value, curr_status[action.status])
	
	curr_status[action.status] = value
	status_changed.emit(action.status, value)	
	
func tick_all_status():
	for key in curr_status.keys():
		tick_status(key, curr_status[key])
	
func tick_status(status: COMBAT.STATUS_TYPE, value: int):
	match status:
		COMBAT.STATUS_TYPE.MEND:
			if curr_armor < get_max_armor():
				var heal = min(value, get_max_armor() - curr_armor)
				curr_armor += heal
				value -= heal
				unit_healed.emit(COMBAT.DEFENSE_TYPE.ARMOR, heal)
				
			if value > 0 and curr_health < get_max_health():
				var heal = min(value, get_max_health() - curr_health)
				if curr_health <= 0 and 0 < curr_health + heal:
					unit_revived.emit()
				curr_health += heal
				unit_healed.emit(COMBAT.DEFENSE_TYPE.HEALTH, heal)
		
		COMBAT.STATUS_TYPE.CORRODE:
			if curr_armor > 0:
				var damage = min(value, curr_armor)
				curr_armor -= damage
				value -= damage
				unit_damaged.emit(COMBAT.DEFENSE_TYPE.ARMOR, damage)
				
			if value > 0 and curr_health > 1:
				var damage = min(value, curr_health - 1)
				curr_health -= damage
				unit_damaged.emit(COMBAT.DEFENSE_TYPE.HEALTH, damage)
		
		COMBAT.STATUS_TYPE.BLESS:
			if curr_health < get_max_health():
				var heal = min(value, get_max_health() - curr_health)
				if curr_health <= 0 and 0 < curr_health + heal:
					unit_revived.emit()
				curr_health += heal
				unit_healed.emit(COMBAT.DEFENSE_TYPE.HEALTH, heal)
				value -= heal
			
			if value > 0 and  curr_mana < get_max_mana():
				var heal = min(value, get_max_mana() - curr_mana)
				curr_mana += heal
				unit_healed.emit(COMBAT.DEFENSE_TYPE.MANA, heal)
		
		COMBAT.STATUS_TYPE.CURSE:
			if curr_health > 1:
				var damage = min(value, curr_health - 1)
				curr_health -= damage
				value -= damage
				unit_damaged.emit(COMBAT.DEFENSE_TYPE.HEALTH, damage)
				
			if value > 0 and curr_mana > 0:
				var damage = min(value, curr_mana)
				curr_mana -= damage
				unit_damaged.emit(COMBAT.DEFENSE_TYPE.MANA, damage)
	
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
	
func start_round():
	if !is_stunned():
		curr_ap = get_max_ap()
		ap_changed.emit()
		
	tick_all_status()
	
	if curr_block != null:
		curr_block = null
		react_changed.emit(COMBAT.REACT_TYPE.BLOCK, 0)
		
	if curr_evade_count > 0:
		curr_evade_count = 0
		react_changed.emit(COMBAT.REACT_TYPE.EVADE, 0)
		
func end_round():
	curr_ap = 0
	ap_changed.emit()

extends Node

class_name EnemyActionData

enum ENEMY_TARGET_PRIORITY {
	SELF,
	LOWEST_ALLY,
	#STATUS_ALLY,
	HIGHEST_ENEMY,
	SECOND_HIGHEST_ENEMY,
	LOWEST_ENEMY,
	SECOND_LOWEST_ENEMY
}

enum ENEMY_TARGET_TYPE {
	SPREAD,
	FOCUS
}

@export var action: BaseActionData
@export var weight: int = 1
@export var priority: ENEMY_TARGET_PRIORITY
@export var type: ENEMY_TARGET_TYPE
@export var target: COMBAT.DEFENSE_TYPE
@export var include_stunned: bool = false

func select_targets(unit: BaseUnitData, players: Array[BaseUnitData], enemies: Array[BaseUnitData]) -> Array[BaseUnitData]:
	var hits = action.hits
	
	if priority == ENEMY_TARGET_PRIORITY.SELF:
		var out: Array[BaseUnitData] = []
		for i in hits:
			out.append(unit)
		return out
	
	var sorted: Array[BaseUnitData]
	if priority == ENEMY_TARGET_PRIORITY.LOWEST_ALLY:
		sorted = enemies.duplicate()
	else:
		sorted = players.duplicate()
	
	var filtered: Array[BaseUnitData] = sorted.filter(func(u): return include_stunned or !u.is_stunned())
	if filtered.size() > 0:
			sorted = filtered
	sorted.sort_custom(unit_sort)
	
	var idx: int = 0
	var direction: int = 1
	match priority:
		ENEMY_TARGET_PRIORITY.LOWEST_ALLY:
			idx = 0
			direction = 1
		ENEMY_TARGET_PRIORITY.HIGHEST_ENEMY:
			idx = sorted.size() - 1
			direction = -1
		ENEMY_TARGET_PRIORITY.SECOND_HIGHEST_ENEMY:
			idx = sorted.size() - 2
			direction = -2
		ENEMY_TARGET_PRIORITY.LOWEST_ENEMY:
			idx = 0
			direction = 1
		ENEMY_TARGET_PRIORITY.SECOND_LOWEST_ENEMY:
			idx = 1
			direction = 2
		
#	Protect against edge case with one item
	if sorted.size() == 1:
		idx = 0
	
	var output: Array[BaseUnitData] = []
	if type == ENEMY_TARGET_TYPE.FOCUS:
		for i in hits:
			output.append(sorted[idx])
	else:
		while output.size() < hits:
			output.append(sorted[idx])
			
			idx += direction
			while idx >= sorted.size():
				idx -= sorted.size()
			while idx < 0:
				idx += sorted.size()
			
	return output
	

func unit_sort(a: BaseUnitData, b: BaseUnitData):
	match target:
		COMBAT.DEFENSE_TYPE.ARMOR:
			return a.curr_armor < b.curr_armor
		COMBAT.DEFENSE_TYPE.MANA:
			return a.curr_mana < b.curr_mana
		COMBAT.DEFENSE_TYPE.HEALTH:
			return a.curr_health < b.curr_health
			

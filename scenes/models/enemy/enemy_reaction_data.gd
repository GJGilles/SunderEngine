extends EnemyActionData

class_name EnemyReactionData

enum ENEMY_REACTION_TRIGGER {
	SELF_LOW,
	ALLY_LOW,
	INCOMING_ATTACK
}

@export var trigger: ENEMY_REACTION_TRIGGER
@export var defense: COMBAT.DEFENSE_TYPE
@export var threshold: int
@export var cooldown: int

var cool_time: int = 0

func is_trigger(unit: EnemyUnitData, enemies: Array[EnemyUnitData], turns: Array[TurnData]) -> bool:
	if cool_time > 0:
		return false
		
	match trigger:
		ENEMY_REACTION_TRIGGER.SELF_LOW:
			return unit.get_curr_stat(defense) <= threshold
		ENEMY_REACTION_TRIGGER.ALLY_LOW:
			for enemy in enemies:
				if enemy.get_curr_stat(defense) <= threshold:
					return true
			return false 
		ENEMY_REACTION_TRIGGER.INCOMING_ATTACK:
			for t in turns:
				if t.time > threshold:
					return false
				
				for target in t.targets:
					if target == unit:
						return true
			
			return false
	
	return false 
	
func run_react():
	cool_time = cooldown

func cool_react():
	if cool_time > 0:
		cool_time -= 1

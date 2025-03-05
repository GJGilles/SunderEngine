extends BaseEnemyTeamData

@export var chongah: EnemyUnitData
var slam: AttackActionData
var shred: AttackActionData
var curl: ReactActionData
var spit: StatusActionData

var turn: int = 0

func _ready() -> void:
	slam = chongah.actions[0]
	shred = chongah.actions[1]
	curl = chongah.actions[2]
	spit = chongah.actions[3]

func choose_actions():
	if turn % 2 == 0:
		choice_queue.append(func(): 
			var high_armor: Array[BaseUnitData] = get_highest_players(COMBAT.DEFENSE_TYPE.ARMOR)
			return try_do_action(spit, chongah, high_armor[0])
		)
		
		choice_queue.append(func(): 
			return try_do_action(curl, chongah, chongah)
		)
		
		choice_queue.append(func(): 
			var high_armor: Array[BaseUnitData] = get_highest_players(COMBAT.DEFENSE_TYPE.ARMOR)
			if high_armor.size() > 1:
				return try_do_action(spit, chongah, high_armor[1])
			else:
				return try_do_action(spit, chongah, high_armor[0])
		)
	else: 
		choice_queue.append(func(): 
			var low_armor: Array[BaseUnitData] = get_lowest_players(COMBAT.DEFENSE_TYPE.ARMOR)
			return try_do_action(shred, chongah, low_armor[0])
		)
		
		choice_queue.append(func(): 
			var low_armor: Array[BaseUnitData] = get_lowest_players(COMBAT.DEFENSE_TYPE.ARMOR)
			return try_do_action(slam, chongah, low_armor[0])
		)
		
		choice_queue.append(func(): 
			var low_armor: Array[BaseUnitData] = get_lowest_players(COMBAT.DEFENSE_TYPE.ARMOR)
			if low_armor.size() > 1:
				return try_do_action(spit, chongah, low_armor[1])
			else:
				return try_do_action(spit, chongah, low_armor[0])
		)
	
	turn += 1

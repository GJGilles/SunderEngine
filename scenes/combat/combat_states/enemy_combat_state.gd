extends BaseCombatState

class_name EnemyCombatState

func _ready():
	async_thread()
	
func async_thread():
	var enemy: EnemyUnitData = overview.curr_turn.source
	var enemies: Array[BaseUnitData] = overview.enemies.characters.values()
	var players: Array[BaseUnitData] = overview.party.characters.values()
	
	var action_ai: EnemyActionData = enemy.get_action(enemies, overview.turns)
	var targets: Array[BaseUnitData] = action_ai.select_targets(enemy, players, enemies)
	
	var turn: TurnData = TurnData.new()
	turn.source = enemy
	turn.action = action_ai.action
	turn.targets = targets
	turn.time = action_ai.action.time_cost
	await overview.insert_turn(turn)
	
	overview.set_state(TurnCombatState.new())
	queue_free()

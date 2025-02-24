extends BaseCombatState

class_name EnemyCombatState

var turn_track: TurnTrackData

func _ready():
	turn_track = overview.turn_track
	
	async_thread()
	
func async_thread():
	var enemy: EnemyUnitData = unit
	var enemies: Array[BaseUnitData] = overview.enemies.characters.values()
	var players: Array[BaseUnitData] = overview.party.characters.values()
	
	var action_ai: EnemyActionData = enemy.get_action(enemies, turn_track.turns)
	var targets: Array[BaseUnitData] = action_ai.select_targets(enemy, players, enemies)
	
	var turn: TurnData = TurnData.new()
	turn.source = enemy
	turn.action = action_ai.action
	turn.targets = targets
	turn.time = action_ai.action.time_cost
	await turn_track.insert_turn(turn)
	
	overview.set_state(TurnCombatState.new(), enemy)
	queue_free()

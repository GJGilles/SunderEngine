extends BaseCombatState

class_name EnemyCombatState

var turn_track: TurnTrackData

var timer: Timer

func _ready():
	turn_track = overview.turn_track
	
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 3.0
	add_child(timer)
	
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
	
	enemy.ready_action(action_ai.action, targets)
	overview.preview_turn(turn)
	
	timer.start()
	await timer.timeout
	
	overview.preview_clear()
	overview.insert_turn(turn)
	
	overview.set_state(TurnCombatState.new(), enemy)
	queue_free()

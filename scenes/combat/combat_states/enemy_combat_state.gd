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
	
	enemy.ready_action(action_ai.action)
	overview.attack_preview.set_values(action_ai.action)
	for t in targets:
		overview.field_dict[t].set_highlight(true)
		overview.field_dict[t].set_target_ticks(targets.count(t))
	
	timer.start()
	await timer.timeout
	overview.attack_preview.visible = false
	
	for t in targets:
		overview.field_dict[t].set_highlight(false)
		overview.field_dict[t].set_target_ticks(0)
	
	var turn: TurnData = TurnData.new()
	turn.source = enemy
	turn.action = action_ai.action
	turn.targets = targets
	turn.time = action_ai.action.time_cost
	await turn_track.insert_turn(turn)
	
	overview.set_state(TurnCombatState.new(), enemy)
	queue_free()

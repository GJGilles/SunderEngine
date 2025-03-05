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
	
	for unit: BaseUnitData in overview.enemies.units.values():
		unit.start_round()
	
	await overview.update_done().wait()
	do_actions()

func do_actions():
	while turn_track.turns.size() > 0:
		var turn: TurnData = turn_track.next_turn()
		turn.source.do_action(turn.action, turn.targets)
		await overview.update_done().wait()
		
	ready_actions()

func ready_actions():
	overview.enemies.action_selected.connect(action_selected)
	overview.enemies.round_done.connect(end_turn)
	overview.enemies.choose_actions()
	overview.enemies.next_action()
	
func action_selected(action: BaseActionData, source: BaseUnitData, targets: Array[BaseUnitData]):
	overview.preview_action(action, source, targets)
	
	timer.start()
	await timer.timeout
	
	overview.preview_clear()
	
	if action is AttackActionData:
		turn_track.add_turn(action, source, targets)
	else:
		source.do_action(action, targets)
		await overview.update_done().wait()
		
	overview.enemies.next_action()
	
func end_turn():
	overview.set_state(PlayerCombatState.new())
	queue_free()

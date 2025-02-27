extends BaseCombatState

class_name TurnCombatState

var turn_track: TurnTrackData
var combat_turn_track: CombatTurnTrack

func _ready():
	turn_track = overview.turn_track
	combat_turn_track = overview.combat_turn_track
	async_thread()

func async_thread():
	var turn: TurnData =  turn_track.next_turn()
	await combat_turn_track.all_done_update().wait()
	
	if turn.action is AttackActionData:
		var attack: AttackActionData = turn.action
		
		for u in turn.targets:
			turn.source.do_action(attack)
			await overview.update_done().wait()
			u.apply_damage(attack.damage, attack.attack, attack.defense)
			await overview.update_done().wait()
		
	elif turn.action is ReactActionData:
		var react: ReactActionData = turn.action
		turn.source.remove_react(react)
		for u in turn.targets:
			u.remove_react(react)

	turn.source.tick_all_status()
	await overview.update_done().wait()
	
	if turn.source.is_stunned():
		turn_track.insert_empty_turn(turn.source)
		await overview.update_done().wait()
		overview.set_state(TurnCombatState.new(), turn.source)
	elif turn.source is PlayerUnitData:
		overview.set_state(PlayerCombatState.new(), turn.source)
	else:
		overview.set_state(EnemyCombatState.new(), turn.source)
	queue_free()

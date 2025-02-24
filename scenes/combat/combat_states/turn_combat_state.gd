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
		
		turn.source.unit_attack.emit(attack)
		
		var promises: Array[Promise] = []
		for u in turn.targets:
			u.apply_damage(attack.damage, attack.attack, attack.defense)
			#promises.append(Promise.from(unit.update_done))
			
		await Promise.all(promises).wait()
		
	elif turn.action is ReactActionData:
		var react: ReactActionData = turn.action
		turn.source.remove_react(react)
		for u in turn.targets:
			u.remove_react(react)

	turn.source.tick_all_status()
		
	if turn.source is PlayerUnitData:
		overview.set_state(PlayerCombatState.new(), turn.source)
	else:
		overview.set_state(EnemyCombatState.new(), turn.source)
	queue_free()

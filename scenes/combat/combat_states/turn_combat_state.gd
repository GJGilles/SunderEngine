extends BaseCombatState

class_name TurnCombatState

func _ready():
	async_thread()

func async_thread():
	await overview.next_turn()
	
	var turn: TurnData = overview.curr_turn
	
	if turn.action is AttackActionData:
		var attack: AttackActionData = turn.action
		
		turn.source.unit_attack.emit(attack)
		
		var promises: Array[Promise] = []
		for unit in turn.targets:
			unit.apply_damage(attack.damage, attack.attack, attack.defense)
			promises.append(Promise.from(unit.update_done))
			
		await Promise.all(promises).wait()
		
	elif turn.action is ReactActionData:
		var react: ReactActionData = turn.action
		turn.source.remove_react(react)
		for unit in turn.targets:
			unit.remove_react(react)

	turn.source.tick_all_status()
		
	if turn.source is PlayerUnitData:
		overview.set_state(PlayerCombatState.new())
	else:
		overview.set_state(EnemyCombatState.new())
	queue_free()

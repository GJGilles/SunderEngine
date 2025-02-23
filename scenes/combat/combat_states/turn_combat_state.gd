extends BaseCombatState

class_name TurnCombatState

func _ready():
	async_thread()

func async_thread():
	await overview.next_turn()
	
	var turn: TurnData = overview.curr_turn
	
	if turn.action is AttackActionData:
		var attack: AttackActionData = turn.action
		
		#await overview.attack_unit(turn.source)
		
		var promises: Array[Promise] = []
		for unit in turn.targets:
			promises.append(overview.damage_unit(unit, attack.damage, attack.attack, attack.defense))
		await Promise.all(promises).wait()
	elif turn.action is ReactActionData:
		var react: ReactActionData = turn.action
#		Remove react from targets

	overview.tick_status()
		
	if turn.source is PlayerUnitData:
		overview.set_state(PlayerCombatState.new())
	else:
		overview.set_state(EnemyCombatState.new())
	queue_free()

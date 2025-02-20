extends BaseCombatState

class_name TurnCombatState

func _ready():
	async_thread()

func async_thread():
	await overview.next_turn()
	
	var turn: TurnData = overview.curr_turn
	
	if turn.action is AttackActionData:
		var attack: AttackActionData = turn.action
		for unit in turn.targets:
			await overview.damage_unit(unit, attack.damage, attack.attack, attack.defense)
	elif turn.action is ReactActionData:
		var react: ReactActionData = turn.action
#		Remove react from targets

	overview.tick_status()
		
	if turn.source is PlayerUnitData:
		overview.set_state(PlayerCombatState.new())
	else:
		overview.set_state(EnemyCombatState.new())

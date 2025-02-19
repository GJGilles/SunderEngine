extends BaseCombatState

class_name TurnCombatState

func _ready():
	async_thread()

func async_thread():
	var turn: TurnData = await overview.async_next_turn()
	
	if turn.isAttack:
		for unit in turn.targets:
			await overview.damage_unit(unit, turn.damage, turn.type)
		
	if turn.source is PlayerUnitData:
		pass

extends BaseCombatState

class_name PlayerCombatState

func _ready():
	async_thread()
	
func async_thread():
	var player: PlayerUnitData = overview.curr_turn.source
	
	overview.show_actions(player.current_class.actions)
	var action: BaseActionData = await overview.action_selected
	overview.hide_actions()
	
	overview.get_enemy_targets(action.hits)
	var targets: Array[BaseUnitData] = await overview.targets_selected
	
	var turn: TurnData = TurnData.new()
	turn.source = player
	turn.action = action
	turn.targets = targets
	turn.time = action.time_cost
	await overview.insert_turn(turn)
	
	overview.set_state(TurnCombatState.new())
	queue_free()

extends BaseCombatState

class_name PlayerCombatState

func _ready():
	async_thread()
	
func async_thread():
	var player: PlayerUnitData = overview.curr_turn.source
	overview.show_actions(player.current_class.actions)
	
	var action_index: int = await overview.action_selected
	overview.hide_actions()

extends BaseCombatState

class_name PlayerCombatState

var player: PlayerUnitData
var action: BaseActionData
var targets: Array[BaseUnitData] = []

func _ready():
	player = overview.curr_turn.source
	overview.show_actions(player.get_all_actions())
	overview.action_selected.connect(action_selected)
	
func action_selected(a: BaseActionData):
	action = a
	overview.hide_actions()
	select_targets()
	
func select_targets():
	match action.target_type:
		COMBAT.TARGET_TYPE.SELF:
			player.unit_selectable.emit(true)
			player.add_target.connect(func(): add_target(player))
		COMBAT.TARGET_TYPE.ALLY:
			for val in overview.party.characters.values():
				val.unit_selectable.emit(true)
				val.add_target.connect(func(): add_target(val))
		COMBAT.TARGET_TYPE.ENEMY:
			for val in overview.enemies.characters.values():
				val.unit_selectable.emit(true)
				val.add_target.connect(func(): add_target(val))
		
func add_target(unit: BaseUnitData):
	targets.append(unit)
	if targets.size() == action.hits:
		unselect_targets()
		create_turn()
	
func remove_target(unit: BaseUnitData):
	var idx = targets.find(unit)
	targets.remove_at(idx)

func unselect_targets():
	for val in overview.party.characters.values() + overview.enemies.characters.values():
		val.unit_selectable.emit(false)
	
func create_turn():
	var turn: TurnData = TurnData.new()
	turn.source = player
	turn.action = action
	turn.targets = targets
	turn.time = action.time_cost
	await overview.insert_turn(turn)
	end_turn()

func end_turn():
	overview.set_state(TurnCombatState.new())
	queue_free()

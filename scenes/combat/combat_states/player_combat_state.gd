extends BaseCombatState

class_name PlayerCombatState

var attack_list: CombatAttackList
var player_field_area: CombatFieldArea
var enemy_field_area: CombatFieldArea
var turn_track: TurnTrackData

var player: PlayerUnitData

var next_turn: TurnData
var action: BaseActionData
var targets: Array[BaseUnitData] = []

func _ready():
	attack_list = overview.combat_attack_list
	player_field_area = overview.player_field_area
	enemy_field_area = overview.enemy_field_area
	turn_track = overview.turn_track
	
	player = unit
	
	attack_list.visible = true
	attack_list.set_values(player.get_all_actions())
	attack_list.item_selected.connect(action_selected)
	
func action_selected(idx: int):
	action = player.get_action(idx)
	attack_list.visible = false
	
	next_turn = TurnData.new()
	next_turn.source = player
	next_turn.action = action
	next_turn.time = action.time_cost
	
	select_targets()
	
func select_targets():
	match action.target_type:
		COMBAT.TARGET_TYPE.SELF:
			var key = overview.party.characters.find_key(player)
			player_field_area.get_value(key).set_selectable(true)
			player_field_area.get_targets(action.hits)
			player_field_area.targets_selected.connect(player_targets_selected)
		COMBAT.TARGET_TYPE.ALLY:
			for key in overview.party.characters.keys():
				player_field_area.get_value(key).set_selectable(true)
			player_field_area.get_targets(action.hits)
			player_field_area.targets_selected.connect(player_targets_selected)
		COMBAT.TARGET_TYPE.ENEMY:
			for key in overview.enemies.characters.keys():
				enemy_field_area.get_value(key).set_selectable(true)
				
			enemy_field_area.targets_changed.connect(func(targets): preview_targets(targets))
			enemy_field_area.on_focused.connect(func(u): preview_targets(enemy_field_area.target_list, u))
			enemy_field_area.on_unfocused.connect(func(_u): preview_targets(enemy_field_area.target_list))
				
			enemy_field_area.get_targets(action.hits)
			enemy_field_area.targets_selected.connect(enemy_targets_selected)
	
func preview_targets(targets: Array[BaseUnitData], unit: BaseUnitData = null):
	var preview: Array[BaseUnitData]
	preview.assign(targets)
	if unit != null:
		preview.append(unit)
	
	next_turn.targets = preview
	overview.preview_clear()
	overview.preview_turn(next_turn)
		
func player_targets_selected(units: Array[BaseUnitData]):
	targets.assign(units)
	next_turn.targets = targets
	for key in overview.party.characters.keys():
		player_field_area.get_value(key).set_selectable(false)
		
	player.ready_action(action, targets)
	await overview.update_done().wait()
	end_turn()
	
func enemy_targets_selected(units: Array[BaseUnitData]):
	targets.assign(units)
	next_turn.targets = targets
	for key in overview.enemies.characters.keys():
		enemy_field_area.get_value(key).set_selectable(false)
		
	player.ready_action(action, targets)
	await overview.update_done().wait()
	end_turn()

func end_turn():
	overview.preview_clear()
	await turn_track.insert_turn(next_turn)
	overview.set_state(TurnCombatState.new(), player)
	queue_free()

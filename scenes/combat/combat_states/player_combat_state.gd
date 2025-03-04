extends BaseCombatState

class_name PlayerCombatState

var attack_list: CombatAttackList
var player_field_area: CombatFieldArea
var enemy_field_area: CombatFieldArea

var player: PlayerUnitData

var next_turn: TurnData
var action: BaseActionData
var targets: Array[BaseUnitData] = []

func _ready():
	attack_list = overview.combat_attack_list
	player_field_area = overview.player_field_area
	enemy_field_area = overview.enemy_field_area
	
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
	
	overview.select_action(action)
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
				
			enemy_field_area.targets_changed.connect(preview_targets)
			enemy_field_area.on_focused.connect(enemy_focused)
			enemy_field_area.on_unfocused.connect(enemy_unfocused)
				
			enemy_field_area.get_targets(action.hits)
			enemy_field_area.targets_selected.connect(enemy_targets_selected)
	
func enemy_focused(u: BaseUnitData):
	preview_targets(enemy_field_area.target_list, u)
	
func enemy_unfocused(_u: BaseUnitData):
	preview_targets(enemy_field_area.target_list)
	
func preview_targets(target_list: Array[BaseUnitData], u: BaseUnitData = null):
	var preview: Array[BaseUnitData]
	preview.assign(target_list)
	if u != null:
		preview.append(u)
	
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
	enemy_field_area.targets_changed.disconnect(preview_targets)
	enemy_field_area.on_focused.disconnect(enemy_focused)
	enemy_field_area.on_unfocused.disconnect(enemy_unfocused)
			
	targets.assign(units)
	next_turn.targets = targets
	for key in overview.enemies.characters.keys():
		enemy_field_area.get_value(key).set_selectable(false)
		
	player.ready_action(action, targets)
	await overview.update_done().wait()
	end_turn()

func end_turn():
	overview.preview_clear()
	overview.insert_turn(next_turn)
	overview.set_state(TurnCombatState.new(), player)
	queue_free()

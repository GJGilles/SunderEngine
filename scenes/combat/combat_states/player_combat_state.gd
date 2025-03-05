extends BaseCombatState

class_name PlayerCombatState

var attack_list: CombatAttackList
var player_field_area: CombatFieldArea
var enemy_field_area: CombatFieldArea

var player: PlayerUnitData
var action: BaseActionData
var targets: Array[BaseUnitData] = []

func _ready():
	attack_list = overview.combat_attack_list
	player_field_area = overview.player_field_area
	enemy_field_area = overview.enemy_field_area
	
	for unit: BaseUnitData in overview.party.units.values():
		unit.start_round()
		await overview.update_done().wait()
			
	set_player_select(true)
	
func set_player_select(selectable: bool):
	for pos in overview.party.units.keys():
		var unit: PlayerUnitData = overview.party.units[pos]
		var field: CombatFieldUnit = player_field_area.get_value(pos)
		field.set_selectable(selectable)
		if selectable:
			field.on_selected.connect(player_selected)
		else:
			field.on_selected.disconnect(player_selected)
		
	
func player_selected(unit: BaseUnitData):
	player = unit
	set_player_select(false)
	
	attack_list.visible = true
	attack_list.set_values(player)
	attack_list.item_selected.connect(action_selected)
	
func action_selected(idx: int):
	action = player.get_action(idx)
	attack_list.visible = false
	attack_list.item_selected.disconnect(action_selected)
	
	#overview.select_action(action)
	select_targets()
	
func select_targets():
	match action.target_type:
		COMBAT.TARGET_TYPE.SELF:
			var key = overview.party.units.find_key(player)
			player_field_area.get_value(key).set_selectable(true)
			player_field_area.get_targets(action.area_type)
			player_field_area.targets_selected.connect(player_targets_selected)
		COMBAT.TARGET_TYPE.ALLY:
			for key in overview.party.units.keys():
				player_field_area.get_value(key).set_selectable(true)
			player_field_area.get_targets(action.area_type)
			player_field_area.targets_selected.connect(player_targets_selected)
		COMBAT.TARGET_TYPE.ENEMY:
			for key in overview.enemies.units.keys():
				enemy_field_area.get_value(key).set_selectable(true)
				
			enemy_field_area.on_focused.connect(enemy_focused)
			enemy_field_area.on_unfocused.connect(enemy_unfocused)
				
			enemy_field_area.get_targets(action.area_type)
			enemy_field_area.targets_selected.connect(enemy_targets_selected)
	
func enemy_focused(unit: BaseUnitData):
	overview.preview_action(action, player, overview.enemies.get_unit_targets(unit, action.area_type))
	
func enemy_unfocused(unit: BaseUnitData):
	overview.preview_clear()
		
func player_targets_selected(units: Array[BaseUnitData]):
	player_field_area.targets_selected.disconnect(player_targets_selected)
	
	targets.assign(units)
	for key in overview.party.units.keys():
		player_field_area.get_value(key).set_selectable(false)
		
	do_action()
	
func enemy_targets_selected(units: Array[BaseUnitData]):
	enemy_field_area.on_focused.disconnect(enemy_focused)
	enemy_field_area.on_unfocused.disconnect(enemy_unfocused)
	enemy_field_area.targets_selected.disconnect(enemy_targets_selected)
			
	targets.assign(units)
	for key in overview.enemies.units.keys():
		enemy_field_area.get_value(key).set_selectable(false)
		
	do_action()

func do_action():
	overview.preview_clear()
	player.do_action(action, targets)
	await overview.update_done().wait()	
	set_player_select(true)

func end_turn():
	overview.preview_clear()
	overview.set_state(EnemyCombatState.new())
	queue_free()

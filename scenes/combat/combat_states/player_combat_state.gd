extends BaseCombatState

class_name PlayerCombatState

var attack_list: CombatAttackList
var player_field_area: CombatFieldArea
var enemy_field_area: CombatFieldArea
var turn_track: TurnTrackData

var player: PlayerUnitData
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
			enemy_field_area.get_targets(action.hits)
			enemy_field_area.targets_selected.connect(enemy_targets_selected)
		
func player_targets_selected(positions: Array[TeamData.POSITION]):
	targets.assign(positions.map(func(p): return overview.party.characters[p]))
	for key in overview.party.characters.keys():
		player_field_area.get_value(key).set_selectable(false)
		
	apply_action()
	create_turn()
	
func enemy_targets_selected(positions: Array[TeamData.POSITION]):
	targets.assign(positions.map(func(p): return overview.enemies.characters[p]))
	for key in overview.enemies.characters.keys():
		enemy_field_area.get_value(key).set_selectable(false)
		
	apply_action()
	create_turn()
	
func apply_action():
	if action is StatusActionData:
		player.do_action(action)
		for t in targets:
			t.apply_status(action)
	elif action is ReactActionData:
		var react: ReactActionData = action
		player.do_action(react)
		react.source = player
		for t in targets:
			t.apply_react(react)
	
func create_turn():
	var turn: TurnData = TurnData.new()
	turn.source = player
	turn.action = action
	turn.targets = targets
	turn.time = action.time_cost
	await turn_track.insert_turn(turn)
	end_turn()

func end_turn():
	overview.set_state(TurnCombatState.new(), player)
	queue_free()

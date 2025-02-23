extends Node2D

class_name CombatOverview

@onready var combat_turn_track: CombatTurnTrack = $CombatUI/CombatTurnTrack

@onready var player_status_zone: CombatStatusZone = $CombatUI/PlayerStatusZone
@onready var enemy_status_zone: CombatStatusZone = $CombatUI/EnemyStatusZone

@onready var player_field_area: CombatFieldArea = $CombatUI/CombatField/PlayerArea
@onready var enemy_field_area: CombatFieldArea = $CombatUI/CombatField/EnemyArea

@onready var combat_attack_list: CombatAttackList = $CombatUI/CombatAttackList

@export var party: TeamData
@export var enemies: TeamData

var turns: Array[TurnData]
var curr_turn: TurnData

signal action_selected(action: BaseActionData)
signal targets_selected(targets: Array[BaseUnitData])

func _ready():
	turns = []
	
	for val in party.characters.values() + enemies.characters.values():
		val.reset_stats()
		
		var t: TurnData = TurnData.new()
		combat_turn_track.add_child(t)
		turns.append(t)
		
		t.time = val.get_speed()
		t.source = val
	
	turns.sort_custom(func (a, b): return a.time < b.time)
	combat_turn_track.set_values(turns)
	
	player_status_zone.set_values(party)
	enemy_status_zone.set_values(enemies)
	
	player_field_area.set_values(party)
	enemy_field_area.set_values(enemies)
	
	set_state(TurnCombatState.new())

func set_state(state: BaseCombatState):
	state.overview = self
	add_child(state)
	
func next_turn() -> Signal:
	curr_turn = turns.pop_front()
	for t in turns:
		t.time -= curr_turn.time
	
	return combat_turn_track.move_track(curr_turn.time)
	
func insert_turn(turn: TurnData):
	var idx: int = 0
	for t in turns:
		if t.time > turn.time:
			break
		idx += 1
		
	turns.insert(idx, turn)
	combat_turn_track.remove_turn(0)
	combat_turn_track.insert_turn(idx, turn)
	
func attack_unit(unit: BaseUnitData) -> Signal:
	if unit is PlayerUnitData:
		var pos: TeamData.POSITION = party.characters.find_key(unit)
		return player_field_area.attack_unit(pos)
	else:
		var pos: TeamData.POSITION = enemies.characters.find_key(unit)
		return enemy_field_area.attack_unit(pos)
	
func damage_unit(unit: BaseUnitData, damage: int, attack: COMBAT.ATTACK_TYPE, defense: COMBAT.DEFENSE_TYPE) -> Promise:
	
	var total: int
	match defense:
		COMBAT.DEFENSE_TYPE.ARMOR:
			unit.curr_armor -= damage
			total = unit.curr_armor
		COMBAT.DEFENSE_TYPE.MANA:
			unit.curr_mana -= damage
			total = unit.curr_mana
		COMBAT.DEFENSE_TYPE.HEALTH:
			if attack == COMBAT.ATTACK_TYPE.PHYSICAL:
				unit.curr_health -= floor(damage * (1 + unit.curr_armor / 100.0))
			else:
				unit.curr_health -= floor(damage * (1 + unit.curr_mana / 100.0))
			total = unit.curr_health
	
	if unit is PlayerUnitData:
		var pos: TeamData.POSITION = party.characters.find_key(unit)
		return Promise.new(
			func(resolve: Callable, reject: Callable):
				await player_field_area.damage_unit(pos)
				await player_status_zone.update_unit(pos, total, defense)
				resolve.call()
		)
	else:
		var pos: TeamData.POSITION = enemies.characters.find_key(unit)
		return Promise.new(
			func(resolve: Callable, reject: Callable):
				await enemy_field_area.damage_unit(pos)
				await enemy_status_zone.update_unit(pos, total, defense)
				resolve.call()
		)
	
func tick_status():
	pass
	
func show_actions(actions: Array[BaseActionData]):
	combat_attack_list.visible = true
	combat_attack_list.set_values(actions)
	
func hide_actions():
	combat_attack_list.visible = false
	
func _on_combat_attack_list_item_selected(index: int) -> void:
	var player: PlayerUnitData = curr_turn.source
	var action: BaseActionData = player.get_action(index)
	action_selected.emit(action)
	
func get_player_targets(num: int):
	player_field_area.get_targets(num)
	
func get_enemy_targets(num: int):
	enemy_field_area.get_targets(num)
	
func select_targets(targets: Array[BaseUnitData]):
	targets_selected.emit(targets)

func _on_player_area_targets_selected(targets: Array[TeamData.POSITION]) -> void:
	var target_units: Array[BaseUnitData] 
	target_units.assign(targets.map(func (t): return party.characters[t]))
	targets_selected.emit(target_units)

func _on_enemy_area_targets_selected(targets: Array[TeamData.POSITION]) -> void:
	var target_units: Array[BaseUnitData] 
	target_units.assign(targets.map(func (t): return enemies.characters[t]))
	targets_selected.emit(target_units)

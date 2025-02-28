extends Node2D

class_name CombatOverview

@onready var turn_track: TurnTrackData = $TurnTrackData
@onready var combat_turn_track: CombatTurnTrack = $CombatUI/CombatTurnTrack

@onready var player_status_zone: CombatStatusZone = $CombatUI/PlayerStatusZone
@onready var enemy_status_zone: CombatStatusZone = $CombatUI/EnemyStatusZone

@onready var player_field_area: CombatFieldArea = $CombatUI/CombatField/PlayerArea
@onready var enemy_field_area: CombatFieldArea = $CombatUI/CombatField/EnemyArea

@onready var combat_attack_list: CombatAttackList = $CombatUI/CombatAttackList
@onready var attack_preview: CombatAttackItem = $CombatUI/AttackPreview

@export var party: TeamData
@export var enemies: TeamData

var status_dict: Dictionary[BaseUnitData, CombatStatusSquare] = {}
var field_dict: Dictionary[BaseUnitData, CombatFieldUnit] = {}
var unit_updates: Dictionary[BaseUnitData, Promise] = {}

func _ready():
	var units: Array[BaseUnitData] = party.characters.values() + enemies.characters.values()
	for u in units:
		u.reset_stats()
		
	turn_track.set_values(units)
	
	player_field_area.set_values(party)
	player_status_zone.set_values(party)
	for key in party.characters.keys():
		status_dict[party.characters[key]] = player_status_zone.get_value(key)
		field_dict[party.characters[key]] = player_field_area.get_value(key)
		register_signals(party.characters[key], player_field_area.get_value(key), player_status_zone.get_value(key))
	
	enemy_status_zone.set_values(enemies)
	enemy_field_area.set_values(enemies)
	for key in enemies.characters.keys():
		status_dict[enemies.characters[key]] = enemy_status_zone.get_value(key)
		field_dict[enemies.characters[key]] = enemy_field_area.get_value(key)
		register_signals(enemies.characters[key], enemy_field_area.get_value(key), enemy_status_zone.get_value(key))
	
	set_state(TurnCombatState.new(), null)

func register_signals(unit: BaseUnitData, field_unit: CombatFieldUnit, status_square: CombatStatusSquare):
	unit_updates[unit] = Promise.resolve()
	
	unit.unit_ready.connect(func(action: BaseActionData): unit_ready(unit, field_unit, status_square, action))
	unit.unit_action.connect(func(action: BaseActionData): unit_action(unit, field_unit, status_square, action))

	unit.attack_evaded.connect(func(): unit_evaded(unit, field_unit, status_square))
	unit.attack_blocked.connect(func(): unit_block(unit, field_unit, status_square))

	unit.unit_damaged.connect(func(type, amount): unit_damaged(unit, field_unit, status_square, type, amount))
	unit.unit_stunned.connect(func(): unit_stunned(unit, field_unit, status_square))
	unit.unit_fainted.connect(func(): unit_fainted(unit, field_unit, status_square))

	unit.unit_healed.connect(func(type, amount): unit_healed(unit, field_unit, status_square, type, amount))
	unit.unit_revived.connect(func(): unit_revived(unit, field_unit, status_square))
	
	unit.status_changed.connect(status_square.status_changed)
	unit.react_changed.connect(status_square.react_changed)
	
func unit_ready(unit: BaseUnitData, field_unit: CombatFieldUnit, status_square: CombatStatusSquare, action: BaseActionData):
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			await status_square.update_stats()
			resolve.call()
	)
	
func unit_action(unit: BaseUnitData, field_unit: CombatFieldUnit, status_square: CombatStatusSquare, action: BaseActionData):
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			if action is ReactActionData:
				var react: ReactActionData = action
				if react.react == COMBAT.REACT_TYPE.EVADE:
					await field_unit.play_dodge().wait()
				else:
					await field_unit.play_block().wait()	
			else:
				await field_unit.play_attack().wait()
			resolve.call()
	)
	
func unit_evaded(unit: BaseUnitData, field_unit: CombatFieldUnit, status_square: CombatStatusSquare):
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			await field_unit.play_dodge().wait()
			resolve.call()
	)
	
func unit_block(unit: BaseUnitData, field_unit: CombatFieldUnit, status_square: CombatStatusSquare):
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			await field_unit.play_block().wait()
			resolve.call()
	)
	
func unit_damaged(unit: BaseUnitData, field_unit: CombatFieldUnit, status_square: CombatStatusSquare, type: COMBAT.DEFENSE_TYPE, amount: int):
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			await Promise.all([
				field_unit.play_damaged(type, amount),
				status_square.update_stats()
			]).wait() 
			resolve.call()
	)
	
func unit_stunned(unit: BaseUnitData, field_unit: CombatFieldUnit, status_square: CombatStatusSquare):
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			#await field_unit.play_damaged().wait()
			#await status_square.update_stats().wait()
			
			var turn: TurnData = turn_track.remove_unit(unit)
			if turn.action is ReactActionData:
				var react: ReactActionData = turn.action
				turn.source.remove_react(react)
				for u in turn.targets:
					u.remove_react(react)
			
			turn_track.insert_empty_turn(unit)
			await combat_turn_track.all_done_update().wait()
			resolve.call()
	)
	
	
func unit_fainted(unit: BaseUnitData, field_unit: CombatFieldUnit, status_square: CombatStatusSquare):
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			resolve.call()
	)
	
func unit_healed(unit: BaseUnitData, field_unit: CombatFieldUnit, status_square: CombatStatusSquare, type: COMBAT.DEFENSE_TYPE, amount: int):
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			await Promise.all([
				field_unit.play_healed(type, amount),
				status_square.update_stats()
			]).wait()
			resolve.call()
	)
	
func unit_revived(unit: BaseUnitData, field_unit: CombatFieldUnit, status_square: CombatStatusSquare):
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			#await field_unit.play_healed().wait()
			#await status_square.update_stats().wait()
			resolve.call()
	)
	
func preview_turn(turn: TurnData):
	attack_preview.set_values(turn.action)
	field_dict[turn.source].set_highlight(COMBAT.OUTLINE_COLOR.GOLD, true)
	for t in turn.targets:
		field_dict[t].set_highlight(COMBAT.OUTLINE_COLOR.WHITE, true)
		field_dict[t].set_target_ticks(turn.targets.count(t))
		
func preview_clear():
	attack_preview.visible = false
	for val in field_dict.values():
		val.set_highlight(COMBAT.OUTLINE_COLOR.GOLD, false)
		val.set_highlight(COMBAT.OUTLINE_COLOR.WHITE, false)
		val.set_target_ticks(0)
	
func update_done() -> Promise:
	return Promise.all(unit_updates.values())

func set_state(state: BaseCombatState, unit: BaseUnitData):
	state.overview = self
	state.unit = unit
	add_child(state)
	

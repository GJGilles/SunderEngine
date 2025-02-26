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
	
	unit.unit_action.connect(func(_action: BaseActionData): pass)

	unit.attack_evaded.connect(func(): pass)
	unit.attack_blocked.connect(func(): pass)

	unit.unit_damaged.connect(func(_type): unit_damaged(unit, field_unit, status_square))
	unit.unit_stunned.connect(func(): unit_stunned(unit, field_unit, status_square))
	unit.unit_fainted.connect(func(): unit_fainted(unit, field_unit, status_square))

	unit.unit_healed.connect(func(_type): status_square.update_stats())
	unit.unit_revived.connect(func(): status_square.update_stats())
	
	unit.status_changed.connect(status_square.status_changed)
	unit.react_changed.connect(status_square.react_changed)
	
func unit_damaged(unit: BaseUnitData, field_unit: CombatFieldUnit, status_square: CombatStatusSquare):
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			await field_unit.play_damaged().wait()
			await status_square.update_stats().wait()
			resolve.call()
	)
	
func unit_stunned(unit: BaseUnitData, field_unit: CombatFieldUnit, status_square: CombatStatusSquare):
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			await field_unit.play_damaged().wait()
			await status_square.update_stats().wait()
			turn_track.remove_unit(unit)
			await combat_turn_track.all_done_update().wait()
			resolve.call()
	)
	
	
func unit_fainted(unit: BaseUnitData, field_unit: CombatFieldUnit, status_square: CombatStatusSquare):
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			await field_unit.play_damaged().wait()
			await status_square.update_stats().wait()
			resolve.call()
	)
	
func update_done() -> Promise:
	return Promise.all(unit_updates.values())

func set_state(state: BaseCombatState, unit: BaseUnitData):
	state.overview = self
	state.unit = unit
	add_child(state)
	

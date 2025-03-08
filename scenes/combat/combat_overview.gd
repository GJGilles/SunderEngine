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
@export var enemies: BaseEnemyTeamData

var status_dict: Dictionary[BaseUnitData, CombatStatusSquare] = {}
var field_dict: Dictionary[BaseUnitData, CombatFieldUnit] = {}
var unit_updates: Dictionary[BaseUnitData, Promise] = {}

var pause_promise: Promise = Promise.resolve()
var pause_resolve: Callable = func(): pass

signal unit_changed(unit: BaseUnitData)
signal turn_start(is_player: bool)
signal combat_done(victory: bool)

signal input_undo()
signal input_end()

func _ready():
	var units: Array[BaseUnitData] = party.units.values() + enemies.units.values()
	for u in units:
		u.reset_stats()
	
	player_field_area.set_values(party)
	player_status_zone.set_values(party)
	for key in party.units.keys():
		status_dict[party.units[key]] = player_status_zone.get_value(key)
		field_dict[party.units[key]] = player_field_area.get_value(key)
		register_signals(party.units[key], player_field_area.get_value(key), player_status_zone.get_value(key))
	
	enemy_status_zone.set_values(enemies)
	enemy_field_area.set_values(enemies)
	for key in enemies.units.keys():
		status_dict[enemies.units[key]] = enemy_status_zone.get_value(key)
		field_dict[enemies.units[key]] = enemy_field_area.get_value(key)
		register_signals(enemies.units[key], enemy_field_area.get_value(key), enemy_status_zone.get_value(key))
	
	set_state(EnemyCombatState.new())

func register_signals(unit: BaseUnitData, field_unit: CombatFieldUnit, status_square: CombatStatusSquare):
	unit_updates[unit] = Promise.resolve()
	
	unit.action_start.connect(func(action: BaseActionData, targets: Array[BaseUnitData]): action_start(unit, action, targets))
	unit.action_hit.connect(func(action: BaseActionData, target: BaseUnitData): action_hit(unit, action, target))
	unit.action_end.connect(func(action: BaseActionData, targets: Array[BaseUnitData]): action_end(unit, action, targets))
	unit.attack_evaded.connect(func(): unit_evaded(unit, field_unit, status_square))
	unit.attack_blocked.connect(func(): unit_block(unit, field_unit, status_square))

	unit.unit_damaged.connect(func(type, amount): unit_damaged(unit, field_unit, status_square, type, amount))
	unit.unit_stunned.connect(func(): unit_stunned(unit, field_unit, status_square))
	unit.unit_fainted.connect(func(): unit_fainted(unit, field_unit, status_square))

	unit.unit_healed.connect(func(type, amount): unit_healed(unit, field_unit, status_square, type, amount))
	unit.unit_revived.connect(func(): unit_revived(unit, field_unit, status_square))
	
	unit.ap_changed.connect(field_unit.show_ap)
	unit.status_changed.connect(status_square.status_changed)
	unit.react_changed.connect(status_square.react_changed)
	
func action_start(unit: BaseUnitData, action: BaseActionData, targets: Array[BaseUnitData]):
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			for t in targets:
				var status_square: CombatStatusSquare = status_dict[t]
				status_square.set_combo_state(true)
			
			resolve.call()
	)
	

func action_hit(unit: BaseUnitData, action: BaseActionData, target: BaseUnitData):
	var last_update: Promise = update_done()
	
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			await last_update.wait()
			
			var field_unit: CombatFieldUnit = field_dict[unit]
			if action is AttackActionData:
				var attack: AttackActionData = action
				await field_unit.play_attack().wait()
				target.apply_damage(attack.damage, attack.attack, attack.defense)
			elif action is StatusActionData:
				var status: StatusActionData = action
				await field_unit.play_attack().wait()
				target.apply_status(status)
			elif action is ReactActionData:
				var react: ReactActionData = action
				if react.react == COMBAT.REACT_TYPE.EVADE:
					await field_unit.play_dodge().wait()
				else:
					await field_unit.play_block().wait()	
				target.apply_react(react)
				
			resolve.call()
	)
	
func action_end(unit: BaseUnitData, action: BaseActionData, targets: Array[BaseUnitData]):
	var last_update: Promise = update_done()
	
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			await last_update.wait()
			
			for t in targets:
				var status_square: CombatStatusSquare = status_dict[t]
				status_square.set_combo_state(false)
				status_square.update_stats()
			
			resolve.call()
	)
	
func unit_evaded(unit: BaseUnitData, field_unit: CombatFieldUnit, _status_square: CombatStatusSquare):
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			await field_unit.play_dodge().wait()
			resolve.call()
	)
	
func unit_block(unit: BaseUnitData, field_unit: CombatFieldUnit, _status_square: CombatStatusSquare):
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
			unit_changed.emit(unit)
			resolve.call()
	)
	
func unit_stunned(unit: BaseUnitData, field_unit: CombatFieldUnit, _status_square: CombatStatusSquare):
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			await field_unit.play_stunned().wait()
			#await status_square.update_stats().wait()
			
			if unit is EnemyUnitData:
				turn_track.remove_unit(unit)
			
			unit_changed.emit(unit)
			resolve.call()
	)
	
	
func unit_fainted(unit: BaseUnitData, _field_unit: CombatFieldUnit, _status_square: CombatStatusSquare):
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			unit_changed.emit(unit)
			resolve.call()
	)
	
func unit_healed(unit: BaseUnitData, field_unit: CombatFieldUnit, status_square: CombatStatusSquare, type: COMBAT.DEFENSE_TYPE, amount: int):
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			await Promise.all([
				field_unit.play_healed(type, amount),
				status_square.update_stats()
			]).wait()
			
			unit_changed.emit(unit)
			resolve.call()
	)
	
func unit_revived(unit: BaseUnitData, _field_unit: CombatFieldUnit, _status_square: CombatStatusSquare):
	unit_updates[unit] = Promise.new(
		func(resolve: Callable, _reject: Callable):
			#await field_unit.play_healed().wait()
			#await status_square.update_stats().wait()
			resolve.call()
	)
	
func preview_turn(turn: TurnData):
	preview_action(turn.action, turn.source, turn.targets)
	
func preview_action(action: BaseActionData, source: BaseUnitData, targets: Array[BaseUnitData]):
	attack_preview.set_values(action, false)
	field_dict[source].set_highlight(COMBAT.OUTLINE_COLOR.GOLD, true)
	
	for t in targets:
		var preview: BaseUnitData = t.clone()
		if action is AttackActionData:
			var attack: AttackActionData = action
			for i in attack.hits:
				preview.apply_damage(attack.damage, attack.attack, attack.defense)
			status_dict[t].preview_stats(preview.curr_health, preview.curr_armor, preview.curr_mana)
			
		field_dict[t].set_highlight(COMBAT.OUTLINE_COLOR.WHITE, true)
		preview.queue_free()
		
func preview_clear():
	attack_preview.visible = false
	for val in field_dict.values():
		val.set_highlight(COMBAT.OUTLINE_COLOR.GOLD, false)
		val.set_highlight(COMBAT.OUTLINE_COLOR.WHITE, false)
		
	for val in status_dict.values():
		val.reset_stats()

func combat_pause():
	pause_promise = Promise.new(func(resolve: Callable, _reject): pause_resolve = resolve)
	
func combat_resume():
	pause_resolve.call()
	
func update_done() -> Promise:
	var promises: Array[Promise] = unit_updates.values()
	promises.append(pause_promise)
	return Promise.all(promises)

func set_state(state: BaseCombatState):
	if state is PlayerCombatState:
		turn_start.emit(true)
	else:
		turn_start.emit(false)
	
	state.overview = self
	add_child(state)
	
func _on_background_gui_input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"):
		input_undo.emit()
		
func _on_end_turn_pressed() -> void:
	input_end.emit()

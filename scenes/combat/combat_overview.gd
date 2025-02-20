extends Node2D

class_name CombatOverview

@onready var combat_turn_track: CombatTurnTrack = $CombatUI/CombatTurnTrack
@onready var player_status_zone: CombatStatusZone = $CombatUI/PlayerStatusZone
@onready var enemy_status_zone: CombatStatusZone = $CombatUI/EnemyStatusZone
@onready var combat_attack_list: CombatAttackList = $CombatUI/CombatAttackList

@export var party: TeamData
@export var enemies: TeamData

var turns: Array[TurnData]
var curr_turn: TurnData

signal action_selected(index: int)
signal targets_selected(targets: Array[BaseUnitData])

func _ready():
	turns = []
	
	for val in party.characters:
		var chara = party.characters[val]
		
		var t: TurnData = TurnData.new()
		combat_turn_track.add_child(t)
		turns.append(t)
		
		t.time = chara.get_speed()
		t.source = chara
	
	turns.sort_custom(func (a, b): return a.time < b.time)
	combat_turn_track.set_values(turns)
	
	player_status_zone.set_values(party)
	enemy_status_zone.set_values(enemies)
	
	set_state(TurnCombatState.new())

func set_state(state: BaseCombatState):
	state.overview = self
	add_child(state)
	
func next_turn() -> Signal:
	curr_turn = turns.pop_front()
	for t in turns:
		t.time -= curr_turn.time
	
	return combat_turn_track.move_track(curr_turn.time)
	
func damage_unit(unit: BaseUnitData, damage: int, attack: COMBAT.ATTACK_TYPE, defense: COMBAT.DEFENSE_TYPE):
	
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
		player_status_zone.update_unit(pos, total, defense)
	else:
		var pos: TeamData.POSITION = enemies.characters.find_key(unit)
		enemy_status_zone.update_unit(pos, total, defense)
	
func tick_status():
	pass
	
func show_actions(actions: Array[BaseActionData]):
	combat_attack_list.visible = true
	combat_attack_list.set_values(actions)
	
func hide_actions():
	combat_attack_list.visible = false
	
func _on_combat_attack_list_item_selected(index: int) -> void:
	action_selected.emit(index)
	
func show_targets():
	pass
	
func select_targets(targets: Array[BaseUnitData]):
	targets_selected.emit(targets)

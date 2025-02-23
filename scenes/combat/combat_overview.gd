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
	
func show_actions(actions: Array[BaseActionData]):
	combat_attack_list.visible = true
	combat_attack_list.set_values(actions)
	
func hide_actions():
	combat_attack_list.visible = false
	
func _on_combat_attack_list_item_selected(index: int) -> void:
	var player: PlayerUnitData = curr_turn.source
	var action: BaseActionData = player.get_action(index)
	action_selected.emit(action)

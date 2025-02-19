extends Node2D

class_name CombatOverview

@onready var combat_turn_track: CombatTurnTrack = $CombatUI/CombatTurnTrack
@onready var player_status_zone: CombatStatusZone = $CombatUI/PlayerStatusZone
@onready var enemy_status_zone: CombatStatusZone = $CombatUI/EnemyStatusZone

@export var party: TeamData
@export var enemies: TeamData

var turns: Array[TurnData]


func _ready():
	turns = []
	
	for val in party.characters:
		var char = party.characters[val]
		
		var t = TurnData.new()
		combat_turn_track.add_child(t)
		turns.append(t)
		
		t.time = char.get_speed()
		t.source = char
		t.isAttack = false
	
	turns.sort_custom(func (a, b): return a.time < b.time)
	combat_turn_track.set_values(turns)
	
	set_state(TurnCombatState.new())

func set_state(state: BaseCombatState):
	state.overview = self
	add_child(state)
	
func async_next_turn() -> TurnData:
	var turn: TurnData = turns.pop_front()
	for t in turns:
		t.time -= turn.time
	
	await combat_turn_track.move_track(turn.time)
	
	return turn
	
func async_damage_unit(unit: BaseUnitData, damage: int, type: AttackType.TYPE):
	pass
	
func async_tick_status():
	pass
	

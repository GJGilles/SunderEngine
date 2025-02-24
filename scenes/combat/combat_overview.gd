extends Node2D

class_name CombatOverview

@onready var turn_track: TurnTrackData = $TurnTrackData
@onready var combat_turn_track: CombatTurnTrack = $CombatUI/CombatTurnTrack

@onready var player_status_zone: CombatStatusZone = $CombatUI/PlayerStatusZone
@onready var enemy_status_zone: CombatStatusZone = $CombatUI/EnemyStatusZone

@onready var player_field_area: CombatFieldArea = $CombatUI/CombatField/PlayerArea
@onready var enemy_field_area: CombatFieldArea = $CombatUI/CombatField/EnemyArea

@onready var combat_attack_list: CombatAttackList = $CombatUI/CombatAttackList

@export var party: TeamData
@export var enemies: TeamData

func _ready():
	var units: Array[BaseUnitData] = party.characters.values() + enemies.characters.values()
	for u in units:
		u.reset_stats()
		
	turn_track.set_values(units)
	
	player_field_area.set_values(party)
	player_status_zone.set_values(party)
	for key in party.characters.keys():
		register_signals(key, party, player_field_area, player_status_zone)
	
	enemy_status_zone.set_values(enemies)
	enemy_field_area.set_values(enemies)
	for key in enemies.characters.keys():
		register_signals(key, enemies, enemy_field_area, enemy_status_zone)
	
	set_state(TurnCombatState.new(), null)

func register_signals(pos: TeamData.POSITION, team: TeamData, field_area: CombatFieldArea, status_zone: CombatStatusZone):
	team.characters[pos].unit_damaged.connect(func(_type): unit_damaged(pos, field_area, status_zone))
	
func unit_damaged(pos: TeamData.POSITION, field_area: CombatFieldArea, status_zone: CombatStatusZone):
	await field_area.get_value(pos).play_damaged()
	await status_zone.get_value(pos).update_stats()

func set_state(state: BaseCombatState, unit: BaseUnitData):
	state.overview = self
	state.unit = unit
	add_child(state)
	

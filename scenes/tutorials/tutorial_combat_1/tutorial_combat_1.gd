extends Node2D

@onready var combat: CombatOverview = $CombatOverview

@onready var chie: PlayerUnitData = $Party/Chie
@onready var raka: PlayerUnitData = $Party/Raka
@onready var chongah: EnemyUnitData = $"Enemies/Chongah"

@export var dialog_tutorial: DialogueResource

func _ready() -> void:
	pass
	#DialogueManager.show_dialogue_balloon(dialog_tutorial, "stats")
	#
	#combat.action_selected.connect(hit_tutorial)
	#combat.turn_inserted.connect(time_tutorial)
	#combat.turn_inserted.connect(enemy_tutorial)

func hit_tutorial(_unit, _turn):
	combat.action_selected.disconnect(hit_tutorial)
	DialogueManager.show_dialogue_balloon(dialog_tutorial, "hit")

func time_tutorial(_turn):
	combat.turn_inserted.disconnect(time_tutorial)
	DialogueManager.show_dialogue_balloon(dialog_tutorial, "time")

func enemy_tutorial(turn: TurnData):
	if turn.source == chongah:
		combat.turn_inserted.disconnect(enemy_tutorial)
		combat.combat_pause()
		DialogueManager.show_dialogue_balloon(dialog_tutorial, "enemy")
		DialogueManager.dialogue_ended.connect(func(_d): combat.combat_resume(), CONNECT_ONE_SHOT)

func weakness_tutorial():
	DialogueManager.show_dialogue_balloon(dialog_tutorial, "weakness")
	
func stun_tutorial():
	DialogueManager.show_dialogue_balloon(dialog_tutorial, "stun")

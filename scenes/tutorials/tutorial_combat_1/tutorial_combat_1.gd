extends Node2D

@onready var combat: CombatOverview = $CombatOverview

@onready var chie: PlayerUnitData = $Party/Chie
@onready var raka: PlayerUnitData = $Party/Raka
@onready var chongah: EnemyUnitData = $"Enemies/Chongah"

@export var dialog_tutorial: DialogueResource

var rounds: int = 0

func _ready() -> void:
	#DialogueManager.show_dialogue_balloon(dialog_tutorial, "stats")
	combat.turn_start.connect(handle_turn_start)

func handle_turn_start(is_player: bool):
	if is_player:
		if rounds == 1:
			show_tutorial("enemy")
		rounds += 1

func show_tutorial(title: String):
		combat.combat_pause()
		DialogueManager.show_dialogue_balloon(dialog_tutorial, title)
		DialogueManager.dialogue_ended.connect(func(_d): combat.combat_resume(), CONNECT_ONE_SHOT)

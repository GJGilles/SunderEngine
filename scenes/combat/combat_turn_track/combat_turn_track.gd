extends Control

class_name CombatTurnTrack

var turn_icon_scene: PackedScene = preload("res://scenes/combat/combat_turn_track/combat_turn_icon.tscn")

@onready var turn_container: HBoxContainer = $TurnContainer

func set_values(turns: Array[TurnData]):
	for t in turns:
		var turn_scene: CombatTurnIcon = turn_icon_scene.instantiate()
		turn_scene.turn = t
		turn_container.add_child(turn_scene)
		
func remove_turn(index: int):
	turn_container.get_child(index).queue_free()
	
func insert_turn(index: int, turn: TurnData):
		var turn_scene: CombatTurnIcon = turn_icon_scene.instantiate()
		turn_scene.set_values(turn)
		turn_container.add_child(turn_scene)
		turn_container.move_child(turn_scene, index)

func move_track(amount: int) -> Signal:
	var done: Signal
	for child: CombatTurnIcon in turn_container.get_children():
		done = child.reduce_time(amount)
	return done

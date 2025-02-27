extends Control

class_name CombatTurnTrack

var turn_icon_scene: PackedScene = preload("res://scenes/combat/combat_turn_track/combat_turn_icon.tscn")

@onready var turn_container: HBoxContainer = $TurnContainer

signal turn_focused(turn: TurnData)
signal unfocused()

func insert_turn(index: int, turn: TurnData):
	var turn_scene: CombatTurnIcon = turn_icon_scene.instantiate()
	turn_scene.turn = turn
	turn_scene.on_focused.connect(func(): turn_focused.emit(turn))
	turn_scene.on_unfocused.connect(func(): unfocused.emit())
	turn_container.add_child(turn_scene)
	turn_container.move_child(turn_scene, index)
		
func remove_turn(index: int):
	var child = turn_container.get_child(index)
	child.remove_turn()
	
func update_turn(index: int, time: int):
	var child: CombatTurnIcon = turn_container.get_child(index)
	child.update_time(time)
	
func all_done_update() -> Promise:
	var promises: Array[Promise]
	promises.assign(turn_container.get_children().map(func(c): return c.update_done))
	return Promise.all(promises)

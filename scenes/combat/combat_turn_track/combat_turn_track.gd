extends Control

class_name CombatTurnTrack

var turn_icon_scene: PackedScene = preload("res://scenes/combat/combat_turn_track/combat_turn_icon.tscn")

@onready var turn_container: HBoxContainer = $TurnContainer

signal turn_focused(turn: TurnData)
signal unfocused()

func add_turn(turn: TurnData):
	var turn_scene: CombatTurnIcon = turn_icon_scene.instantiate()
	turn_scene.turn = turn
	turn_scene.on_focused.connect(func(): turn_focused.emit(turn))
	turn_scene.on_unfocused.connect(func(): unfocused.emit())
	turn_container.add_child(turn_scene)
		
func remove_turn(index: int):
	var child = turn_container.get_child(index)
	child.remove_turn()


func _on_turn_track_data_added_turn(turn: TurnData) -> void:
	pass # Replace with function body.

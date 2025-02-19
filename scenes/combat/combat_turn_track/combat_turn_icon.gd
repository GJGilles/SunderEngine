extends Control

class_name CombatTurnIcon

@onready var portrait: TextureRect = $Portrait
@onready var time: Label = $HBoxContainer/Time

var turn: TurnData

func _ready():
	portrait.texture = turn.source.get_portrait()
	time.text = str(turn.time)
	
func reduce_time(t: int) -> Signal:
	var curr: int = int(time.text)
	
	var tween = create_tween()
	tween.tween_method(set_time, curr, curr - t, 1)
	return tween.finished
	
func set_time(t: int):
	time.text = str(t)

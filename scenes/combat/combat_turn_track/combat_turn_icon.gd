extends Control

class_name CombatTurnIcon

@onready var portrait: TextureRect = $Portrait
@onready var time: Label = $HBoxContainer/Time

var turn: TurnData
var update_done: Promise = Promise.resolve()

signal on_focused()
signal on_unfocused()

func _ready():
	portrait.texture = turn.source.get_portrait()
	time.text = str(turn.time)
	
func update_time(t: int):
	await update_done.wait()
	
	var curr: int = int(time.text)
	var tween = create_tween()
	tween.tween_method(set_time, curr, t, 1)
	update_done = Promise.from(tween.finished)
	
func set_time(t: int):
	time.text = str(t)

func remove_turn():
	await update_done.wait()
	get_parent().remove_child(self)
	queue_free()
	


func _on_focus_entered() -> void:
	on_focused.emit()

func _on_focus_exited() -> void:
	on_unfocused.emit()

func _on_mouse_entered() -> void:
	on_focused.emit()

func _on_mouse_exited() -> void:
	on_unfocused.emit()

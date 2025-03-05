extends Control

class_name CombatTurnIcon

@onready var portrait: TextureRect = $Portrait

var turn: TurnData

signal on_focused()
signal on_unfocused()

func _ready():
	portrait.texture = turn.source.get_portrait()

func remove_turn():
	get_parent().remove_child(self)
	queue_free()
	
func _on_focused():
	portrait.material = COMBAT.get_outline_resource(COMBAT.OUTLINE_COLOR.GOLD)
	on_focused.emit()
	
func _on_unfocused():
	portrait.material = null
	on_unfocused.emit()

func _on_focus_entered() -> void:
	_on_focused()

func _on_focus_exited() -> void:
	_on_unfocused()

func _on_mouse_entered() -> void:
	_on_focused()

func _on_mouse_exited() -> void:
	_on_unfocused()

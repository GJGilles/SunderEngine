extends Control

class_name CombatStatusIcon

@onready var icon: TextureRect = $Icon
@onready var label: Label = $Label

func set_status(status: COMBAT.STATUS_TYPE, value: int):
	icon.texture = COMBAT.get_status_icon(status)
	label.text = str(value)

func set_react(react: COMBAT.REACT_TYPE, value: int):
	icon.texture = COMBAT.get_react_icon(react)
	label.text = str(value)
	

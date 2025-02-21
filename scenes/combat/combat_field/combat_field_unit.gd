extends Control

class_name CombatFieldUnit

@onready var sprite_2d: Sprite2D = $Sprite2D

func set_values(unit: BaseUnitData):
	sprite_2d.texture = unit.sprite
	
func set_empty():
	sprite_2d.texture = null

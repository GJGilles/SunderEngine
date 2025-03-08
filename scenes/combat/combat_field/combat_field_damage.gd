extends Control

class_name CombatFieldDamage

@onready var label: Label = $Label
@onready var player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	player.play("play")
	player.animation_finished.connect(func(_name): 
		get_parent().remove_child(self)
		queue_free()
	)

func set_value(value: String):
	label.text = value

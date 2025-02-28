extends Control

class_name CombatStatusStatBar

@onready var background: ColorRect = $Background
@onready var update_bar: ProgressBar = $UpdateBar
@onready var stat_bar: ProgressBar = $UpdateBar/StatBar
@onready var damage_delay: Timer = $DamageDelay
@onready var label: Label = $Label

var update_done: Promise = Promise.resolve()

func set_value(value: int):
	background.size.x = 150.0 * (100.0 + value) / 200.0
	update_bar.value = value
	stat_bar.value = value
	label.text = str(value) + "%"

func update_value(value: int):
	if value == stat_bar.value:
		return
	
	update_done = Promise.new(
		func(resolve: Callable, _reject: Callable):
			if value > stat_bar.value:
				update_bar.value = value
				label.text = str(value) + "%"
				damage_delay.start()
				
				await damage_delay.timeout
				
				var tween = create_tween()
				tween.tween_property(stat_bar, "value", value, 1)
				await tween.finished
			else:
				stat_bar.value = value
				label.text = str(value) + "%"
				damage_delay.start()
				
				await damage_delay.timeout
				
				var tween = create_tween()
				tween.tween_property(update_bar, "value", value, 1)
				await tween.finished
				
			resolve.call()
	)
	
		

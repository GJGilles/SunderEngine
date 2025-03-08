extends Control

class_name CombatStatusStatBar

@onready var background: ColorRect = $Background
@onready var update_bar: ProgressBar = $UpdateBar
@onready var stat_bar: ProgressBar = $UpdateBar/StatBar
@onready var damage_delay: Timer = $DamageDelay
@onready var label: Label = $Label

var update_done: Promise = Promise.resolve()

func set_max_value(value: int):
	set_value(value)
	background.set_deferred("size", Vector2(150.0 * (100.0 + value) / 200.0, background.size.y))

func set_value(value: int):
	update_bar.value = value
	stat_bar.value = value
	label.text = str(value) + "%"

func set_update(value: int):
	if value > stat_bar.value:
		update_bar.value = value
	else:
		stat_bar.value = value

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
	
func preview_change(value: int, preview: int):
	if preview > value:
		stat_bar.value = value
		update_bar.value = preview
		label.text = "%s" % [str(value)]
	elif preview < value:
		update_bar.value = value
		stat_bar.value = preview
		label.text = "%s" % [str(value)]

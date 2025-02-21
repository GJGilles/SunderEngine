extends Panel

class_name CombatStatusSquareController

@onready var title = $Portrait/Title
@onready var portrait = $Portrait

@onready var health_bar = $HealthBar
@onready var armor_bar = $ArmorBar
@onready var mana_bar = $ManaBar

	
func set_values(unit: BaseUnitData):
	title.text = unit.name
	portrait.texture = unit.get_portrait()
	health_bar.value = unit.curr_health
	armor_bar.value =  unit.curr_armor
	mana_bar.value = unit.curr_mana
	
func set_empty():
	title.text = ""
	portrait.texture = null
	health_bar.value = -100
	armor_bar.value = -100
	mana_bar.value = -100

func update_health(value: float):
	var tween = create_tween()
	tween.tween_property(health_bar, "value", value, 1)
	return tween.finished
	
func update_armor(value: float):
	var tween = create_tween()
	tween.tween_property(armor_bar, "value", value, 1)
	return tween.finished
	
func update_mana(value: float):
	var tween = create_tween()
	tween.tween_property(mana_bar, "value", value, 1) 
	return tween.finished

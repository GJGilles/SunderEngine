extends Panel

class_name CombatStatusSquare

@onready var title = $Portrait/Title
@onready var portrait = $Portrait

@onready var health_bar = $HealthBar
@onready var armor_bar = $ArmorBar
@onready var mana_bar = $ManaBar

var base_unit: BaseUnitData
	
func set_values(unit: BaseUnitData):
	title.text = unit.name
	portrait.texture = unit.get_portrait()
	health_bar.value = unit.curr_health
	armor_bar.value =  unit.curr_armor
	mana_bar.value = unit.curr_mana
	
	base_unit = unit
	
func set_empty():
	title.text = ""
	portrait.texture = null
	health_bar.value = -100
	armor_bar.value = -100
	mana_bar.value = -100
	
func update_stats():
	if health_bar.value != base_unit.curr_health:
		update_health()
		
	if armor_bar.value != base_unit.curr_armor:
		update_armor()
		
	if mana_bar.value != base_unit.curr_mana:
		update_mana()

func update_health():
	var tween = create_tween()
	tween.tween_property(health_bar, "value", base_unit.curr_health, 1)
	await tween.finished
	
func update_armor():
	var tween = create_tween()
	tween.tween_property(armor_bar, "value", base_unit.curr_armor, 1)
	await tween.finished
	
func update_mana():
	var tween = create_tween()
	tween.tween_property(mana_bar, "value", base_unit.curr_mana, 1) 
	await tween.finished

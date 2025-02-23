extends Panel

class_name CombatStatusSquareController

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
	unit.unit_damaged.connect(func(_damage, defense): update_stat(defense))
	unit.unit_stunned.connect(func(): update_health())
	unit.unit_fainted.connect(func(): update_health())
	unit.unit_healed.connect(func(_heal, defense):update_stat(defense))
	unit.unit_revived.connect(func(_heal): update_health())
	
func set_empty():
	title.text = ""
	portrait.texture = null
	health_bar.value = -100
	armor_bar.value = -100
	mana_bar.value = -100
	
func update_stat(stat: COMBAT.DEFENSE_TYPE):
	match stat:
		COMBAT.DEFENSE_TYPE.HEALTH:
			update_health()
		COMBAT.DEFENSE_TYPE.ARMOR:
			update_armor()
		COMBAT.DEFENSE_TYPE.MANA:
			update_mana()

func update_health():
	await base_unit.animation_done
	
	var tween = create_tween()
	tween.tween_property(health_bar, "value", base_unit.curr_health, 1)
	await tween.finished
	
	base_unit.update_done.emit()
	
func update_armor():
	await base_unit.animation_done
	
	var tween = create_tween()
	tween.tween_property(armor_bar, "value", base_unit.curr_armor, 1)
	await tween.finished
	
	base_unit.update_done.emit()
	
func update_mana():
	await base_unit.animation_done
	
	var tween = create_tween()
	tween.tween_property(mana_bar, "value", base_unit.curr_mana, 1) 
	await tween.finished
	
	base_unit.update_done.emit()

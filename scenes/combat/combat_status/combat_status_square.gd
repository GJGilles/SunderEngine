extends Panel

class_name CombatStatusSquare

const COMBAT_STATUS_ICON = preload("res://scenes/combat/combat_status/combat_status_icon.tscn")

@onready var title = $Portrait/Title
@onready var portrait = $Portrait

@onready var health_bar: CombatStatusStatBar = $HealthBar
@onready var armor_bar: CombatStatusStatBar = $ArmorBar
@onready var mana_bar: CombatStatusStatBar = $ManaBar

@onready var status_container: HBoxContainer = $Portrait/StatusContainer
@onready var react_container: HBoxContainer = $Portrait/ReactContainer

var curr_status: Dictionary[COMBAT.STATUS_TYPE, CombatStatusIcon] = {}
var curr_react: Dictionary[COMBAT.REACT_TYPE, CombatStatusIcon] = {}

var base_unit: BaseUnitData
	
func set_values(unit: BaseUnitData):
	title.text = unit.name
	portrait.texture = unit.get_portrait()
	health_bar.set_value(unit.curr_health)
	armor_bar.set_value(unit.curr_armor)
	mana_bar.set_value(unit.curr_mana)
	
	base_unit = unit
	
func set_empty():
	visible = false
	
func all_update_done() -> Promise:
	return Promise.all([
		health_bar.update_done,
		armor_bar.update_done,
		mana_bar.update_done
	])
	
func update_stats() -> Promise:
	return Promise.new(
		func(resolve: Callable, _reject: Callable):
			await all_update_done().wait()
			
			health_bar.update_value(base_unit.curr_health)
			armor_bar.update_value(base_unit.curr_armor)
			mana_bar.update_value(base_unit.curr_mana)
				
			await all_update_done().wait()
			resolve.call()
	)
	
func status_changed(type: COMBAT.STATUS_TYPE, value: int):
	if value == 0:
		if curr_status.has(type):
			var child: CombatStatusIcon = curr_status[type]
			curr_status.erase(type)
			status_container.remove_child(child)
			child.queue_free()
	else:
		var child: CombatStatusIcon
		if curr_status.has(type):
			child = curr_status[type]
		else:
			child = COMBAT_STATUS_ICON.instantiate()
			status_container.add_child(child)
			curr_status[type] = child
		
		child.set_status(type, value)
	
func react_changed(type: COMBAT.REACT_TYPE, value: int):
	if value == 0:
		if curr_react.has(type):
			var child: CombatStatusIcon = curr_react[type]
			curr_react.erase(type)
			react_container.remove_child(child)
			child.queue_free()
	else:
		var child: CombatStatusIcon
		if curr_react.has(type):
			child = curr_react[type]
		else:
			child = COMBAT_STATUS_ICON.instantiate()
			react_container.add_child(child)
			curr_react[type] = child
		
		child.set_react(type, value)

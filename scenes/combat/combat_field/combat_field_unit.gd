extends Control

class_name CombatFieldUnit

const COMBAT_UNIT_TARGET_MARKER = preload("res://scenes/combat/combat_field/combat_unit_target_marker.tscn")
const COMBAT_FIELD_OUTLINE = preload("res://scenes/combat/combat_field/combat_field_outline.tres")

@onready var sprite: CombatFieldUnitAnim = $AnimatedSprite2D
@onready var target_marker_row: HBoxContainer = $TargetMarkerRow
@onready var debounce: Timer = $Debounce

var base_unit: BaseUnitData

var is_selectable: bool = false

signal on_selected()

func _on_gui_input(event: InputEvent):
	if is_selectable and debounce.is_stopped() and event.is_action("ui_select"):
		on_selected.emit()
		debounce.start()
	
func set_values(unit: BaseUnitData):
	sprite.set_values(unit.combat_sprite)
	
	base_unit = unit
	
func set_empty():
	sprite.set_empty()

func set_highlight(value: bool):
	if value:
		sprite.material = COMBAT_FIELD_OUTLINE
	else:
		sprite.material = null

func set_selectable(selectable: bool):
	if selectable:
		is_selectable = true
		set_highlight(true)
	else:
		is_selectable = false
		set_highlight(false)
		for child in target_marker_row.get_children():
			child.queue_free()

func add_target_tick():
	var child = COMBAT_UNIT_TARGET_MARKER.instantiate()
	target_marker_row.add_child(child)
	
func remove_target_tick():
	var child = target_marker_row.get_child(0)
	target_marker_row.remove_child(child)
	child.queue_free()
	
func set_target_ticks(num: int):
	while num > target_marker_row.get_children().size():
		add_target_tick()
		
	while  num < target_marker_row.get_children().size():
		remove_target_tick()
	
func play_damaged() -> Promise:
	return Promise.from(sprite.play_damaged())

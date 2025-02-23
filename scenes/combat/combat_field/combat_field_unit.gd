extends Control

class_name CombatFieldUnit

const COMBAT_UNIT_TARGET_MARKER = preload("res://scenes/combat/combat_field/combat_unit_target_marker.tscn")

@onready var sprite: CombatFieldUnitAnim = $AnimatedSprite2D
@onready var selectable_area: ColorRect = $SelectableArea
@onready var target_marker_row: HBoxContainer = $TargetMarkerRow

var is_empty: bool = true
var is_selectable: bool = false

signal on_selected()

func _on_gui_input(event: InputEvent):
	if is_selectable and event.is_action("ui_select"):
		on_selected.emit()
	
func set_values(unit: BaseUnitData):
	sprite.set_values(unit.combat_sprite)
	is_empty = false
	
func set_empty():
	sprite.set_empty()
	is_empty = true

func set_selectable():
	if not is_empty:
		selectable_area.visible = true
		is_selectable = true
	
func set_unselectable():
	selectable_area.visible = false
	is_selectable = false
	set_target_ticks(0)
	
func set_target_ticks(num: int):
	for child in target_marker_row.get_children():
		child.queue_free()
		
	for i in num: 
		var child = COMBAT_UNIT_TARGET_MARKER.instantiate()
		target_marker_row.add_child(child)

func add_target_tick():
	var child = COMBAT_UNIT_TARGET_MARKER.instantiate()
	target_marker_row.add_child(child)
	
func play_damaged():
	return sprite.play_damaged()
	
func play_attack():
	return sprite.play_attack()

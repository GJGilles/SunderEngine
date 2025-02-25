extends Control

class_name CombatFieldUnit

const COMBAT_UNIT_TARGET_MARKER = preload("res://scenes/combat/combat_field/combat_unit_target_marker.tscn")

@onready var sprite: CombatFieldUnitAnim = $AnimatedSprite2D
@onready var selectable_area: ColorRect = $SelectableArea
@onready var target_marker_row: HBoxContainer = $TargetMarkerRow

var base_unit: BaseUnitData

var is_selectable: bool = false

signal on_selected()

func _on_gui_input(event: InputEvent):
	if is_selectable and event.is_action("ui_select"):
		on_selected.emit()
	
func set_values(unit: BaseUnitData):
	sprite.set_values(unit.combat_sprite)
	
	base_unit = unit
	
func set_empty():
	sprite.set_empty()

func set_selectable(selectable: bool):
	if selectable:
		selectable_area.visible = true
		is_selectable = true
	else:
		selectable_area.visible = false
		is_selectable = false
		for child in target_marker_row.get_children():
			child.queue_free()

func add_target_tick():
	var child = COMBAT_UNIT_TARGET_MARKER.instantiate()
	target_marker_row.add_child(child)
	
func remove_target_tick():
	var child = target_marker_row.get_child(0)
	target_marker_row.remove_child(child)
	child.queue_free()
	
func play_damaged() -> Promise:
	return Promise.from(sprite.play_damaged())

extends Control

class_name CombatFieldUnit

const COMBAT_UNIT_MARKER = preload("res://scenes/combat/combat_field/combat_unit_marker.tscn")

@onready var sprite: CombatFieldUnitAnim = $SpriteBox/Control/Sprite
@onready var marker_row: HBoxContainer = $MarkerRow
@onready var damage_label: Label = $DamageLabel
@onready var debounce: Timer = $Debounce
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var base_unit: BaseUnitData

var is_selectable: bool = false

var outline_dict: Dictionary[COMBAT.OUTLINE_COLOR, bool] = {}

signal on_selected(unit: BaseUnitData)
signal on_focused()
signal on_unfocused()

func _on_gui_input(event: InputEvent):
	if is_selectable and debounce.is_stopped() and event.is_action("ui_select"):
		on_selected.emit(base_unit)
		debounce.start()
	
func set_values(unit: BaseUnitData):
	sprite.set_values(unit.combat_sprite)
	
	base_unit = unit
	
func set_empty():
	sprite.set_empty()

func set_highlight(color: COMBAT.OUTLINE_COLOR, value: bool):
	if value:
		outline_dict[color] = true
	else:
		outline_dict.erase(color)
		
	for val in COMBAT.OUTLINE_COLOR.values():
		if outline_dict.has(val):
			sprite.material = COMBAT.get_outline_resource(val)
			return
	
	sprite.material = null

func set_selectable(selectable: bool):
	if selectable:
		is_selectable = true
		set_highlight(COMBAT.OUTLINE_COLOR.BLUE, true)
	else:
		unfocused()
		is_selectable = false
		set_highlight(COMBAT.OUTLINE_COLOR.BLUE, false)

func add_marker():
	var child = COMBAT_UNIT_MARKER.instantiate()
	marker_row.add_child(child)
	
func remove_marker():
	var child = marker_row.get_child(0)
	marker_row.remove_child(child)
	child.queue_free()
	
func set_num_markers(num: int):
	while num > marker_row.get_children().size():
		add_marker()
		
	while  num < marker_row.get_children().size():
		remove_marker()
	
func show_ap():
	set_num_markers(base_unit.curr_ap)
	
func play_attack() -> Promise:
	animation_player.play("attack")
	audio_player.play()
	return Promise.all([
		sprite.play_animation("attack"),
		Promise.from(animation_player.animation_finished),
		Promise.from(audio_player.finished)
	])
	
func play_block() -> Promise:
	return sprite.play_animation("block")
	
func play_damaged(_type: COMBAT.DEFENSE_TYPE, amount: int) -> Promise:
	damage_label.text = "-" + str(amount)
	damage_label.add_theme_color_override("font_color", Color(1, 0, 0))
	animation_player.play("damage_text")
	
	return Promise.all([ 
		sprite.play_animation("damaged"),
		Promise.from(animation_player.animation_finished)
	])

func play_dodge() -> Promise:
	return sprite.play_animation("dodge")
	
func play_healed(_type: COMBAT.DEFENSE_TYPE, amount: int) -> Promise:
	damage_label.text = "+" + str(amount)
	damage_label.add_theme_color_override("font_color", Color(0, 1, 0))
	animation_player.play("damage_text")
	
	return Promise.all([
		sprite.play_animation("healed"), 
		Promise.from(animation_player.animation_finished)
	])
	
func play_stunned() -> Promise:
	return sprite.play_animation("stunned")

func focused():
	if is_selectable:
		on_focused.emit()
		
func unfocused():
	if is_selectable:
		on_unfocused.emit()

func _on_focus_entered() -> void:
	focused()


func _on_focus_exited() -> void:
	unfocused()


func _on_mouse_entered() -> void:
	focused()


func _on_mouse_exited() -> void:
	unfocused()

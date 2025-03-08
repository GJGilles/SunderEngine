extends Control

class_name CombatAttackItem

const COMBAT_ATTACK_SELECTED = preload("res://scenes/combat/combat_attack_list/combat_attack_selected.tres")

@onready var panel: Panel = $Panel
@onready var _name = $Panel/Name
@onready var _hits = $Panel/Info/Hits
@onready var _damage = $Panel/Info/Damage
@onready var _damage_icon = $Panel/Info/DamageIcon
@onready var _vs: Label = $Panel/Info/VS
@onready var _type_icon = $Panel/Info/TypeIcon
@onready var _mana = $Panel/Cost/Mana
@onready var _mana_icon: TextureRect = $Panel/Cost/ManaIcon
@onready var _time = $Panel/Cost/Time

var is_enabled: bool = false

signal on_selected()

func set_values(action: BaseActionData, enabled: bool):
	visible = true
	is_enabled = enabled
	
	if action != null:
		_name.text = action.name
		_hits.text = str(action.hits) + "x "
		
		if action.mana_cost == 0:
			_mana.visible = false
			_mana_icon.visible = false
		else:
			_mana.visible = true
			_mana_icon.visible = true
			_mana.text = str(action.mana_cost)
			
		_time.text = str(action.ap_cost)
	
	if action is AttackActionData:
		var attack: AttackActionData = action
		_damage.text = str(attack.damage)
		_damage_icon.texture = COMBAT.get_attack_icon(attack.attack)
		_vs.visible = true
		_type_icon.visible = true
		_type_icon.texture = COMBAT.get_defense_icon(attack.defense)
	elif action is StatusActionData:
		var status: StatusActionData = action
		_damage.text = str(status.value)
		_damage_icon.texture = COMBAT.get_status_icon(status.status)
		_vs.visible = false
		_type_icon.visible = false
	elif action is ReactActionData:
		var react: ReactActionData = action
		_damage.text = str(react.value)
		_damage_icon.texture = COMBAT.get_react_icon(react.react)
		_vs.visible = false
		_type_icon.visible = false
	else:
		visible = false

func focused():
	if is_enabled:
		panel.theme = COMBAT_ATTACK_SELECTED
	
func unfocused():
	panel.theme = null

func _on_panel_focus_entered() -> void:
	focused()

func _on_panel_focus_exited() -> void:
	unfocused()
	
func _on_panel_mouse_entered() -> void:
	focused()

func _on_panel_mouse_exited() -> void:
	unfocused()

func _on_panel_gui_input(event: InputEvent) -> void:
	if event.is_action("ui_select") and is_enabled:
		on_selected.emit()
		accept_event()

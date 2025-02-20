extends Control

class_name CombatAttackItem

const COMBAT_ATTACK_SELECTED = preload("res://scenes/combat/combat_attack_list/combat_attack_selected.tres")

@onready var panel: Panel = $Panel
@onready var _name = $Panel/Name
@onready var _hits = $Panel/Info/Hits
@onready var _damage = $Panel/Info/Damage
@onready var _damage_icon = $Panel/Info/DamageIcon
@onready var _type_icon = $Panel/Info/TypeIcon
@onready var _mana = $Panel/Cost/Mana
@onready var _mana_icon: TextureRect = $Panel/Cost/ManaIcon
@onready var _time = $Panel/Cost/Time

signal on_selected()

func set_values(action: BaseActionData):
	
	if action is AttackActionData:
		var attack: AttackActionData = action
		_name.text = attack.name
		_hits.text = str(attack.hits) + "x "
		_damage.text = str(attack.damage)
		_damage_icon.texture = COMBAT.get_attack_icon(attack.attack)
		_type_icon.texture = COMBAT.get_defense_icon(attack.defense)
		
		if attack.mana_cost == 0:
			_mana.visible = false
			_mana_icon.visible = false
		else:
			_mana.text = str(attack.mana_cost)
			
		_time.text = str(attack.time_cost)
	else:
		pass

func focused():
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
	if event.is_action("ui_select"):
		on_selected.emit()

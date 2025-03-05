extends Control

class_name CombatAttackList

@onready var primary: CombatAttackItem = $Attacks/Primary
@onready var secondary: CombatAttackItem = $Attacks/Secondary
@onready var auxilary: CombatAttackItem = $Attacks/Auxilary
@onready var response: CombatAttackItem = $Attacks/Response

signal item_selected(index: int)

func set_values(player: PlayerUnitData):
	var actions: Array[BaseActionData] = player.get_all_actions()
	primary.set_values(actions[0], player.can_do_action(actions[0]))
	secondary.set_values(actions[1], player.can_do_action(actions[1]))
	auxilary.set_values(actions[2], player.can_do_action(actions[2]))
	response.set_values(actions[3], player.can_do_action(actions[3]))

func _on_primary_selected() -> void:
	item_selected.emit(0)


func _on_secondary_selected() -> void:
	item_selected.emit(1)


func _on_auxilary_selected() -> void:
	item_selected.emit(2)


func _on_response_selected() -> void:
	item_selected.emit(3)

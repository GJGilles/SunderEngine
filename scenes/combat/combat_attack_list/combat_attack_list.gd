extends Control

class_name CombatAttackList

@onready var primary: CombatAttackItem = $Attacks/Primary
@onready var secondary: CombatAttackItem = $Attacks/Secondary
@onready var auxilary: CombatAttackItem = $Attacks/Auxilary
@onready var response: CombatAttackItem = $Attacks/Response

signal item_selected(index: int)

func set_values(actions: Array[BaseActionData]):
	primary.set_values(actions[0])
	secondary.set_values(actions[1])
	auxilary.set_values(actions[2])
	
	primary.grab_focus()
	
	


func _on_primary_selected() -> void:
	item_selected.emit(0)


func _on_secondary_selected() -> void:
	item_selected.emit(1)


func _on_auxilary_selected() -> void:
	item_selected.emit(2)


func _on_response_selected() -> void:
	item_selected.emit(3)

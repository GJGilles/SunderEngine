extends Control

class_name CombatAttackList

@onready var primary: CombatAttackItem = $Attacks/Primary
@onready var secondary: CombatAttackItem = $Attacks/Secondary
@onready var auxilary: CombatAttackItem = $Attacks/Auxilary
@onready var response: CombatAttackItem = $Attacks/Response

func set_values(attack: ClassAttackData):
	pass
	

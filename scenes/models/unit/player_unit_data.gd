extends BaseUnitData

class_name PlayerUnitData


@export var current_class: ClassData

func get_speed():
	return current_class.base_speed

func get_max_health():
	return current_class.base_health
	
func get_max_armor():
	return current_class.base_armor
	
func get_max_mana():
	return current_class.base_mana
	
func get_action(idx: int):
	return current_class.actions[idx]

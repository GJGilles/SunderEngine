extends BaseUnitData

class_name PlayerUnitData


@export var current_class: ClassData
@export var current_react: ReactActionData

func get_max_ap():
	return current_class.base_ap

func get_max_health():
	return current_class.base_health
	
func get_max_armor():
	return current_class.base_armor
	
func get_max_mana():
	return current_class.base_mana
	
func get_all_actions() -> Array[BaseActionData]:
	var actions: Array[BaseActionData]
	actions.assign(current_class.actions + [current_react])
	return actions
	
func get_action(idx: int):
	return get_all_actions()[idx]

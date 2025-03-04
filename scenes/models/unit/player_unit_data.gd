extends BaseUnitData

class_name PlayerUnitData


@export var current_class: ClassData
@export var current_react: ReactActionData

@export var override_speed: int

func get_speed():
	return override_speed if override_speed else current_class.base_speed

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

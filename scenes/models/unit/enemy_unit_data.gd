extends BaseUnitData

class_name EnemyUnitData

@export var ranged: bool = false
@export var speed: int
@export var health: int
@export var armor: int
@export var mana: int

@export var actions: Array[EnemyActionData]
@export var reactions: Array[EnemyReactionData]

var action_idx: int = 0

func is_ranged() -> bool:
	return false

func get_portrait() -> Texture2D:
	return portrait

func get_speed() -> int:
	return speed

func get_max_health() -> int:
	return health
	
func get_max_armor() -> int:
	return armor
	
func get_max_mana() -> int:
	return mana
	
func get_action(enemies: Array[BaseUnitData], turns: Array[TurnData]) -> EnemyActionData:
	var action: EnemyActionData = get_reaction(enemies, turns)
	if action != null:
		return action
	
	action = actions[action_idx]
	action_idx += 1
	if action_idx >= actions.size():
		action_idx = 0
	return action
	
func get_reaction(enemies: Array[BaseUnitData], turns: Array[TurnData]) -> EnemyActionData:
	for react in reactions:
		if react.is_trigger(self, enemies, turns):
			react.run_react()
			return react
		else:
			react.cool_react()
	return null

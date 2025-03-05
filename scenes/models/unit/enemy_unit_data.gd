extends BaseUnitData

class_name EnemyUnitData

@export var ranged: bool = false
@export var ap: int
@export var health: int
@export var armor: int
@export var mana: int

@export var actions: Array[BaseActionData]

func is_ranged() -> bool:
	return false

func get_portrait() -> Texture2D:
	return portrait

func get_max_ap() -> int:
	return ap

func get_max_health() -> int:
	return health
	
func get_max_armor() -> int:
	return armor
	
func get_max_mana() -> int:
	return mana

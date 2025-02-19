extends Panel

class_name CombatAttackItem

@onready var _name = $Name
@onready var _hits = $Info/Hits
@onready var _damage = $Info/Damage
@onready var _damage_icon = $Panel/Info/DamageIcon
@onready var _type_icon = $Info/TypeIcon
@onready var _mana = $Cost/Mana
@onready var _time = $Cost/Time

func set_values(title: String, hits: int, damage: int, type: AttackType.TYPE, mana: int, time: int):
	_name.text = title
	_hits.text = hits
	_damage.text = damage
	_damage_icon.texture = AttackType.Instance.get_type_icon(type)
	#_type_icon.texture =
	_mana.text = mana
	_time.text = time

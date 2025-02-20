extends EnemyActionData

class_name EnemyReactionData

enum ENEMY_REACTION_TRIGGER {
	SELF_LOW,
	ALLY_LOW,
	INCOMING_ATTACK
}

@export var trigger: ENEMY_REACTION_TRIGGER

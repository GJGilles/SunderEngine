extends AnimatedSprite2D

class_name CombatFieldUnitAnim

func set_values(spr: SpriteFrames):
	sprite_frames = spr
	play_idle()
	animation_finished.connect(play_idle)
	
func set_empty():
	sprite_frames = null
	
func play_idle():
	play("idle")
	
func play_damaged():
	play("damaged")
	return animation_finished
	
func play_attack():
	play("attack")
	return animation_finished
	

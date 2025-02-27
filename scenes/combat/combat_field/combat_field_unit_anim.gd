extends AnimatedSprite2D

class_name CombatFieldUnitAnim

var update_done: Promise = Promise.resolve()

func set_values(spr: SpriteFrames):
	sprite_frames = spr
	play_idle()
	animation_finished.connect(play_idle)
	
func set_empty():
	sprite_frames = null
	
func play_idle():
	play("idle")
	
func play_animation(anim: String) -> Promise:
	update_done = Promise.new(
		func(resolve: Callable, reject: Callable):
			await update_done.wait()
			if sprite_frames.has_animation(anim):
				sprite_frames.set_animation_loop(anim, false)
				play(anim)
				await animation_finished
				resolve.call()
			else:
				reject.call(Promise.Rejection.new(anim + " does not exist!"))
	)
	return update_done

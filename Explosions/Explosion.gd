extends Node2D

onready var Explosion = $AnimatedSprite
var exists_explosion = true

func _process(delta):
	if exists_explosion and Explosion.frame == 6:
		Explosion.playing = false
		remove_child(Explosion)
		exists_explosion = false
		pass
	pass


func _on_AudioTimer_timeout():
	queue_free()
	pass # Replace with function body.

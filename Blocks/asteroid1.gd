extends Block

class_name Asteroid1

onready var sprite = $CollisionShape2D/Sprite
var counter = 0
var incrementing = 0.01
var is_on_screen = false

func _ready():
	randomize()
	sprite.global_rotation += randf() * 2
	pass

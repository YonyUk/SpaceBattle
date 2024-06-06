extends Node2D

onready var bulletInstacer = preload("res://Shooter/Bullet.tscn")
onready var Director = $Director
onready var Sound = $Sound
onready var SoundTimer = $AudioTimer

var LIMIT_X = 0
var LIMIT_Y = 0
var Damage := 300

func SetDamage(damage: int) -> void:
	Damage = damage
	pass

func Shoot(owner:String =''):
	Sound.play()
	SoundTimer.start()
	var bullet = bulletInstacer.instance()
	bullet.SetDirection(Director.global_position - global_position)
	bullet.SetMapLimits(Vector2(LIMIT_X,LIMIT_Y))
	bullet.global_position = Director.global_position
	bullet.SetOwner(owner)
	bullet.SetDamage(Damage)
	return bullet

func SetMapLimits(vector:Vector2):
	LIMIT_X = vector.x
	LIMIT_Y = vector.y
	pass


func _on_AudioTimer_timeout():
	Sound.stop()
	SoundTimer.stop()
	pass # Replace with function body.

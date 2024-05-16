extends Node2D

onready var bulletInstacer = preload("res://Shooter/Bullet.tscn")
onready var Director = $Director

var LIMIT_X = 0
var LIMIT_Y = 0

func Shoot(owner:String =''):
	var bullet = bulletInstacer.instance()
	bullet.SetDirection(Director.global_position - global_position)
	bullet.SetMapLimits(Vector2(LIMIT_X,LIMIT_Y))
	bullet.global_position = Director.global_position
	return bullet

func SetMapLimits(vector:Vector2):
	LIMIT_X = vector.x
	LIMIT_Y = vector.y
	pass

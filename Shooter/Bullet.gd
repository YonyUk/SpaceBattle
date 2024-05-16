extends Area2D

var IDS = AreasIDS.new()
var ID = IDS.BulletID
var TEAM = ''
var Speed = 40
var Movement = Vector2()
var LIMIT_X = 0
var LIMIT_Y = 0

func SetMapLimits(vector:Vector2) -> void:
	LIMIT_X = vector.x
	LIMIT_Y = vector.y
	pass

func SetOwner(owner: String) -> void:
	TEAM = owner
	pass

func SetDirection(dir:Vector2) -> void:
	Movement = dir
	pass

func _physics_process(delta):
	translate(Movement.normalized() * Speed)
	if global_position.x > LIMIT_X or global_position.x < 0 or global_position.y < 0 or global_position.y > LIMIT_Y:
		queue_free()
		pass
	pass


func _on_Bullet_body_entered(body):
	queue_free()
	pass # Replace with function body.

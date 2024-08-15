extends Area2D

onready var Explosion = preload("res://Explosions/Explosion.tscn")

var IDS = AreasIDS.new()
var ID = IDS.BulletID
var TEAM = ''
var Speed = 40
var Movement = Vector2()
var LIMIT_X = 0
var LIMIT_Y = 0
var Damage := 100

func SetDamage(value: int) -> void:
	Damage = value
	pass

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
	if global_position.x > LIMIT_X + 80 or global_position.x < - 80 or global_position.y < - 80 or global_position.y > LIMIT_Y + 80:
		queue_free()
		pass
	pass

func SelfDelete() -> void:
	queue_free()
	pass

func _on_Bullet_body_entered(body):
	var explosion = Explosion.instance()
	explosion.global_position = global_position
	get_tree().current_scene.AddExplosion(explosion)
	call_deferred("SelfDelete")
	pass # Replace with function body.

func _on_Bullet_area_entered(area):
	if area.ID == IDS.SoldierID:
		var friendly_fire = get_tree().current_scene.GetFriendlyFire()
		var interact = false
		if area.TEAM == TEAM and friendly_fire:
			interact = true
			pass
		elif area.TEAM == TEAM:
			interact = false
			pass
		else:
			interact = true
			pass
		if interact:
			area.Destroy(Damage)
			var explosion = Explosion.instance()
			explosion.global_position = global_position
			get_tree().current_scene.AddExplosion(explosion)
			call_deferred("SelfDelete")
			pass
		pass
	pass # Replace with function body.

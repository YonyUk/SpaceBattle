extends Node

class_name CommanderPerception

var flagFound = false
var underAttack = false
var flagInTargetPos = false
var bulletCloseToFlag = false
var SoldiersShooted = []
var Enemys = []
var Bullets = []
var EnemyPositions = []
var stack_size = 20

func setBulletCloseToFlag(value:bool) -> void:
	bulletCloseToFlag = value
	pass

func setSoldiersShooted(soldiers:Array) -> void:
	SoldiersShooted = soldiers
	pass

func setBullets(bullets: Array) -> void:
	Bullets = bullets
	pass

func setEnemys(enemys: Array) -> void:
	Enemys = enemys
	for enemy in enemys:
		EnemyPositions.push_front(enemy)
		pass
	while EnemyPositions.size() > stack_size:
		EnemyPositions.pop_back()
		pass
	pass

func _compute_distance_average_bettwen_enemys(pos:Vector2) -> float:
	var result = 0
	for en in EnemyPositions:
		if en == pos: continue
		var distance = (pos - en).length_squared()
		result += distance
		pass
	return result / (EnemyPositions.size() - 1)

func _compute_distance_to_flag(enemy,pos:Vector2) -> float:
	return sqrt((pos - enemy.global_position).length_squared())

func setFlagInTargetPos(value:bool) -> void:
	flagInTargetPos = value
	pass

func setFlagFound(value:bool) -> void:
	flagFound = value
	pass

func setUnderAttack(value:bool) -> void:
	underAttack = value
	pass

func FlagFound() -> bool:
	return flagFound

func UnderAttack() -> bool:
	return underAttack

func FlagInTargetPos() -> bool:
	return flagInTargetPos

func EnemysSeen() -> bool:
	return Enemys.size() > 0

func BulletsSeen() -> bool:
	return Bullets.size() > 0

func ShootedSoldiers() -> bool:
	return SoldiersShooted.size()

func BulletCloseToFlag() -> bool:
	return bulletCloseToFlag

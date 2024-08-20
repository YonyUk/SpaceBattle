extends Node

class_name CommanderPerception

var flagFound = false
var underAttack = false
var flagInTargetPos = false
var bulletCloseToFlag = false
var SoldiersShooted = []
var Enemys = []
var Bullets = []

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
	pass

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

extends Node

class_name CommanderPerception

var flagFound = false
var underAttack = false
var flagInTargetPos = false
var Enemys = []

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

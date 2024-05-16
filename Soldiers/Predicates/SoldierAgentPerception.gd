extends Node

class_name SoldierAgentPerception
# this clas represents the perception of an agent

var SelfState := AgentState.new()
var LifePoints := 0
var CurrentPosition := Vector2()
var TargetPosition := Vector2()
var Shooted := false
var EnemysSeen := []
var DefendingDistance: float = 0
var DetectedEnemy = null
var LowLimitLifePoints := 0

func SetSelfState(state:AgentState) -> void:
	SelfState = state
	pass

func SetStateMoving(value:bool) -> void:
	SelfState.SetMoving(value)
	pass

func SetStateAttacking(value: bool) -> void:
	SelfState.SetAttacking(value)
	pass

func SetAutoDefending(value:bool) -> void:
	SelfState.SetAutoDefending(value)
	pass

func SetDefending(value:bool) -> void:
	SelfState.SetDefending(value)
	pass

func SetCanShoot(value:bool) -> void:
	SelfState.SetCanShoot(value)
	pass

func SetCanHide(value:bool) -> void:
	SelfState.SetCanHide(value)
	pass

func SetCanRotate(value:bool) -> void:
	SelfState.SetCanRotate(value)
	pass

func Moving() -> bool:
	return SelfState.Moving()

func Attacking() -> bool:
	return SelfState.Attacking()

func AutoDefending() -> bool:
	return SelfState.AutoDefending()

func Defending() -> bool:
	return SelfState.Defending()

func CanShoot() -> bool:
	return SelfState.CanShoot()

func CanHide() -> bool:
	return SelfState.CanHide()

func CanRotate() -> bool:
	return SelfState.CanRotate()

func SetLowLimitLifePoints(limit:int) -> void:
	LowLimitLifePoints = limit
	pass

func SetLifePoints(points) -> void:
	LifePoints = points
	pass

func SetCurrentPosition(pos:Vector2) -> void:
	CurrentPosition = pos
	pass

func SetTargetPosition(target:Vector2) -> void:
	TargetPosition = target
	pass

func SetShooted(value:bool) -> void:
	Shooted = value
	pass

func SetEnemysSeen(enemys:Array) -> void:
	EnemysSeen = enemys
	pass

func SetDefendingDistance(distance:float) -> void:
	DefendingDistance = distance
	pass

func SetEnemyDetected(enemy) -> void:
	DetectedEnemy = enemy
	pass

func EnemySeen():
	return DetectedEnemy

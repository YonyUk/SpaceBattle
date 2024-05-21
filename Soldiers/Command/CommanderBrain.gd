extends Node

class_name CommanderBrain

var InternalGameState = GameState.new()
var SelfFlagPosition = Vector2()
var SelfTeam = ''
var Allys = []
var MinShipsDefenders = 0
var DistanceToSelfFlagAverage = 0
var DistanceAverageToFlagTeam = 0
var CurrentDefendersCount = 0
var MinDistanceToTeam = 0

func SetMinDefenders(defenders: int) -> void:
	MinShipsDefenders = defenders
	pass

func SetFlagPosition(pos: Vector2) -> void:
	SelfFlagPosition = pos
	pass

func SetAllys(allys: Array) -> void:
	Allys = allys
	pass

func SetTeam(team: String) -> void:
	SelfTeam = team
	pass

func SetGameState(defenders: int,flag_position: Vector2,allys: Array,team: String) -> void:
	SetMinDefenders(defenders)
	SetFlagPosition(flag_position)
	SetAllys(allys)
	SetTeam(team)
	pass

func BrainReady() -> void:
	InternalGameState.SetFlagLocation(SelfTeam,SelfFlagPosition)
	InternalGameState.SetTeam(SelfTeam,Allys)
	pass

func CheckConstraints(team: String) -> bool:
	if CurrentDefendersCount - MinShipsDefenders < 0:
		return false
	DistanceToSelfFlagAverage = InternalGameState.DistanceAverageToSelfFlag(SelfTeam)
	DistanceAverageToFlagTeam = InternalGameState.DistanceAverageFromTeamToFlag(team,SelfTeam)
	if DistanceAverageToFlagTeam - DistanceToSelfFlagAverage < 0:
		return false
	return true

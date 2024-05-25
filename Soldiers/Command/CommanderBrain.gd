extends Node

class_name CommanderBrain

var HEAP = StrategyHeapMin.new()
var InternalGameState = GameState.new()
var SelfFlagPosition = Vector2()
var SelfTeam = ''
var Allys = []
var MinShipsDefenders = 0
var DistanceToSelfFlagAverage = 0
var DistanceAverageToFlagTeam = 0
var CurrentDefendersCount = 0
var MinDistanceToTeam = 0
var GameMap: Map = null
var MapSectors := []
var BlocksSize := 0
var LastsShipsOrdered := []
var SectorsCount = 0
var MaxShipsToOrder = 0
var DefensiveRatio = 0

func SetSectorsCount(count: int) -> void:
	SectorsCount = count
	pass

func SetEnemyFlagPosition(team: String,pos: Vector2) -> void:
	InternalGameState.SetFlagLocation(team,pos)
	pass

func SetBlocksSize(size: float) -> void:
	BlocksSize = size
	pass

func SetCurrentDefenders(defenders: int) -> void:
	CurrentDefendersCount = defenders
	pass

func SetGameMap(map:Map) -> void:
	GameMap = map
	pass

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

func SetEnemys(team: String,ships: Array) -> void:
	InternalGameState.SetTeam(team,ships)
	pass

func SetDefensiveRatio(ratio: int) -> void:
	DefensiveRatio = ratio
	pass

func SetGameState(defenders: int,flag_position: Vector2,allys: Array,team: String) -> void:
	SetMinDefenders(defenders)
	SetFlagPosition(flag_position)
	SetAllys(allys)
	SetTeam(team)
	InternalGameState.SetTeam(team,allys)
	InternalGameState.SetFlagLocation(team,flag_position)
	pass

func SetMinDistanceToTeam(distance: float) -> void:
	MinDistanceToTeam = distance
	pass

func BrainReady() -> void:
	InternalGameState.SetFlagLocation(SelfTeam,SelfFlagPosition)
	InternalGameState.SetTeam(SelfTeam,Allys)
	pass

func CheckConstraints(team: String) -> bool:
	CurrentDefendersCount = 0
	for ship in Allys:
		var vector_distance: Vector2 = ship.global_position - SelfFlagPosition
		var distance = vector_distance.length_squared()
		if sqrt(distance) < DefensiveRatio:
			CurrentDefendersCount += 1
			pass
		pass
	if CurrentDefendersCount - MinShipsDefenders < 0:
		return false
	DistanceToSelfFlagAverage = InternalGameState.DistanceAverageToSelfFlag(SelfTeam)
	DistanceAverageToFlagTeam = InternalGameState.DistanceAverageFromTeamToFlag(team,SelfTeam)
	if DistanceAverageToFlagTeam - DistanceToSelfFlagAverage < 0:
		return false
	if InternalGameState.GetMinDistanceFromTeamTo(SelfTeam,team) < MinDistanceToTeam:
		return false
	return true

func BuildMapSectors() -> void:
	var MapArea = GameMap.XSize() * GameMap.YSize()
	var sectors_area = MapArea / SectorsCount
	var sectors_dimentions = int(sqrt(sectors_area))
	for i in range(0,GameMap.XSize(),sectors_dimentions):
		for j in range(0,GameMap.YSize(),sectors_dimentions):
			MapSectors.append(Vector2(i,j))
			pass
		pass
	GetMaxShipsToOrder()
	pass

func IsFull(array: Array) -> bool:
	for value in array:
		if not value:
			return false
		pass
	return true

func GetMaxShipsToOrder() -> void:
	while pow(MaxShipsToOrder + 1,SectorsCount) < pow(10,7):
		MaxShipsToOrder += 1
		pass
	pass

# AStar to find the best strategy
func GetStrategy(enemy_team: String) -> GameState:
	if LastsShipsOrdered.size() == Allys.size():
		LastsShipsOrdered.clear()
		pass
	for ship in Allys:
		var discrete_position = Vector2(int(ship.global_position.x / BlocksSize),int(ship.global_position.y / BlocksSize))
		InternalGameState.AssignPositionToShip(ship,discrete_position)
		InternalGameState.AssignShipState(ship,ship.GetSoldierState())
		pass
	var ships_taken := []
	HEAP.Clear()
	HEAP.Push(InternalGameState,0)
	var self_flag_distance_average = InternalGameState.DistanceAverageToSelfFlag(SelfTeam)
	var other_flag_distance_average = InternalGameState.DistanceAverageFromTeamToFlag(SelfTeam,enemy_team)
	# searching the strategy
	while not CheckConstraints(SelfTeam) and HEAP.Count() > 0 and ships_taken.size() < MaxShipsToOrder:
		# TODO
		pass
	return InternalGameState

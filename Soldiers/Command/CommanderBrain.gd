extends Node

class_name CommanderBrain

var HEAPS = {}
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
var OffsetPosition := Vector2()
var LastsShipsOrdered := []
var SectorsCount = 0
var MaxShipsToOrder = 0
var DefensiveRatio = 0
var States = ShipStates.new()

func SetSectorsCount(count: int) -> void:
	SectorsCount = count
	pass

func SetEnemyFlagPosition(team: String,pos: Vector2) -> void:
	InternalGameState.SetFlagLocation(team,pos)
	pass

func SetBlocksSize(size: float) -> void:
	BlocksSize = size
	pass

func SetOffsetPosition(offset: Vector2) -> void:
	OffsetPosition = offset
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
	DefensiveRatio = ratio / BlocksSize
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

# rest add new constraints to the algorithm
func CheckConstraints(team: String) -> bool:
	CurrentDefendersCount = 0
	for ship in InternalGameState.ShipsPositionsAssigned.keys():
		var vector_distance: Vector2 = InternalGameState.ShipsPositionsAssigned[ship] - SelfFlagPosition
		var distance = vector_distance.length_squared()
		if sqrt(distance / 2) < DefensiveRatio / 2:
			CurrentDefendersCount += 1
			InternalGameState.ShipsStateAssigned[ship] = States.ShipStateDefend
			pass
		else:
			InternalGameState.ShipsStateAssigned[ship] = States.ShipStateIdle
			pass
		pass
	if CurrentDefendersCount - MinShipsDefenders < 0:
		return false
	DistanceToSelfFlagAverage = InternalGameState.DistanceAverageToSelfFlag(SelfTeam)
	DistanceAverageToFlagTeam = InternalGameState.DistanceAverageFromTeamToFlag(team,SelfTeam)
	if DistanceToSelfFlagAverage - DistanceAverageToFlagTeam < 0:
		return false
	var min_dis_to_self_flag = InternalGameState.MinDistanceFromTeamToFlagTeam(SelfTeam,SelfTeam)
	var min_dis_from_other = InternalGameState.MinDistanceFromTeamToFlagTeam(team,SelfTeam)
	if min_dis_from_other - min_dis_to_self_flag < 0:
		return false
	return true

func BuildMapSectors() -> void:
	var MapArea = GameMap.XSize() * GameMap.YSize()
	var sectors_area = MapArea / SectorsCount
	var sectors_dimentions = int(sqrt(sectors_area))
	if DefensiveRatio < sectors_dimentions:
		DefensiveRatio = sectors_dimentions * 2
		pass  
	for i in range(0,GameMap.XSize(),sectors_dimentions):
		for j in range(0,GameMap.YSize(),sectors_dimentions):
			var sector = Vector2(i,j) + Vector2(sectors_dimentions / 2,sectors_dimentions / 2)
			sector = GameMap.GetFreeCellCloserTo(sector)
			MapSectors.append(sector)
			pass
		pass
	MapSectors.append(SelfFlagPosition)
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

func TransitionFunctionCost(state:GameState) -> float:
	var result = 0
	for ship in state.ShipsPositionsAssigned.keys():
		var discrete_position = Vector2(int(ship.global_position.x / BlocksSize),int(ship.global_position.y / BlocksSize))
		result += (discrete_position - state.ShipsPositionsAssigned[ship]).length_squared()
		pass
	return result

# build the priority queue for the posibilities of one ship
func BuildStatesShips(ship) -> StrategyHeapMin:
	var result = StrategyHeapMin.new()
	for sector in MapSectors:
		var state = GameState.new()
		for ship_ally in Allys:
			if not ship_ally == ship:
				var discrete_position = Vector2(int(ship_ally.global_position.x / BlocksSize),int(ship_ally.global_position.y / BlocksSize))
				state.AssignPositionToShip(ship_ally,discrete_position)
				pass
			pass
		state.AssignPositionToShip(ship,sector)
		var cost = TransitionFunctionCost(state)
		result.Push(state,cost)
		pass
	return result

# AStar for the strategy
func GetStrategy(team:String) -> GameState:
	for ship in Allys:
		var discrete_position = Vector2(int(ship.global_position.x / BlocksSize),int(ship.global_position.y / BlocksSize))
		InternalGameState.AssignPositionToShip(ship,discrete_position)
		InternalGameState.AssignShipState(ship,States.ShipStateIdle)
		HEAPS[ship] = BuildStatesShips(ship)
		pass
	while not CheckConstraints(SelfTeam):
		var heap_min = null
		var ship_moved = null
		var cost = pow(10,10)
		var exists_transition = false
		for heap in HEAPS.keys():
			if HEAPS[heap].Count() > 0 and HEAPS[heap].Peek()[0] < cost:
				if heap.GetSoldierState() == States.ShipStateDefend:
					continue
				exists_transition = true
				heap_min = HEAPS[heap]
				cost = HEAPS[heap].Peek()[0]
				ship_moved = heap
				pass
			pass
		if not exists_transition:
			break
		var state = heap_min.Pop()
		InternalGameState.AssignPositionToShip(ship_moved,state.ShipsPositionsAssigned[ship_moved])
		pass
	return InternalGameState

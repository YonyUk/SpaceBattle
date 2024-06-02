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
var MinShipsSeekerCount = 5
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
var PointObjetive = Vector2(0,0)
var Seekers = []
var Defenders = []

var DefendersConstraints = false
var SelfFlagAverageDistanceConstraint = false
var ShipsSeekerConstraint = false

func SetSectorsCount(count: int) -> void:
	SectorsCount = count
	pass

func SetObjetivePoint(point: Vector2) -> void:
	PointObjetive = point
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

func CheckDefendersConstraints() -> bool:
	CurrentDefendersCount = 0
	for ship in InternalGameState.ShipsPositionsAssigned.keys():
		var vector_distance: Vector2 = InternalGameState.ShipsPositionsAssigned[ship] - SelfFlagPosition
		var distance = vector_distance.length_squared()
		if sqrt(distance / 2) < DefensiveRatio:
			CurrentDefendersCount += 1
			ship.SetDefendingPosition(InternalGameState.ShipsPositionsAssigned[ship])
			InternalGameState.AssignShipState(ship,States.ShipStateDefend)
			pass
		else:
			InternalGameState.ShipsStateAssigned[ship] = ship.GetSoldierState()
			pass
		pass
	if CurrentDefendersCount - MinShipsDefenders < 0:
		DefendersConstraints = false
		return false
	DefendersConstraints = true
	return true

func SelfFlagAverageDistance(team: String) -> bool:
	DistanceToSelfFlagAverage = InternalGameState.DistanceAverageToSelfFlag(SelfTeam)
	DistanceAverageToFlagTeam = InternalGameState.DistanceAverageFromTeamToFlag(team,SelfTeam)
	if DistanceAverageToFlagTeam - DistanceToSelfFlagAverage < 0:
		SelfFlagAverageDistanceConstraint = false
		return false
	SelfFlagAverageDistanceConstraint = true
	return true

func ResolveAverageDistance(team: String) -> void:
	var movements = {}
	for ship in Allys:
		if not InternalGameState.ShipsStateAssigned[ship] == States.ShipStateDefend and not ship in Seekers:
			var sectors_priority = SetSectorsPriority(InternalGameState.ShipsPositionsAssigned[ship])
			movements[ship] = sectors_priority
			pass
		pass
	while InternalGameState.DistanceAverageToSelfFlag(SelfTeam) > InternalGameState.DistanceAverageFromTeamToFlag(team,SelfTeam):
		var current_cost = 0
		var ship_to_move = null
		var exists_transition = false
		for ship in movements.keys():
			if movements[ship].Length() == 0:
				continue
			if not ship_to_move:
				ship_to_move = ship
				current_cost = movements[ship].Peek()[0]
				continue
			if movements[ship].Peek()[0] < current_cost:
				current_cost = movements[ship].Peek()[0]
				ship_to_move = ship
				exists_transition = true
				pass
			pass
		if not exists_transition:
			break
		InternalGameState.AssignPositionToShip(ship_to_move,movements[ship_to_move].Pop())
		pass
	pass

func CheckShipsSeekerConstraint() -> bool:
	for ship in InternalGameState.ShipsPositionsAssigned.keys():
		var vector_distance: Vector2 = InternalGameState.ShipsPositionsAssigned[ship] - PointObjetive
		var distance = vector_distance.length_squared()
		if sqrt(distance / 2) < DefensiveRatio:
			Seekers.append(ship)
			InternalGameState.AssignShipState(ship,States.ShipStateSeeking)
			pass
		else:
			InternalGameState.AssignShipState(ship,InternalGameState.ShipsStateAssigned[ship])
			pass
		pass
	if Seekers.size() - MinShipsSeekerCount < 0:
		ShipsSeekerConstraint = false
		return false
	ShipsSeekerConstraint = true
	return true

# rest add new constraints to the algorithm
func CheckConstraints(team: String) -> bool:
	if not CheckDefendersConstraints():
		return false
	
	if not CheckShipsSeekerConstraint():
		return false

	if not SelfFlagAverageDistance(team):
		return false
#	var min_dis_to_self_flag = InternalGameState.MinDistanceFromTeamToFlagTeam(SelfTeam,SelfTeam)
#	var min_dis_from_other = InternalGameState.MinDistanceFromTeamToFlagTeam(team,SelfTeam)
#	if min_dis_from_other - min_dis_to_self_flag < 0:
#		return false
	return true

func ResolveDefendersConflicts() -> void:
	if CurrentDefendersCount - MinShipsDefenders < 0:
		var defenders_priority = SetDefendersPriority()
		var sectors_priority = SetSectorsPriority(SelfFlagPosition)
		while CurrentDefendersCount < MinShipsDefenders:
			if defenders_priority.Count() == 0 or sectors_priority.Length() == 0:
				break
			var ship = defenders_priority.Pop()
			if InternalGameState.ShipsStateAssigned[ship] == States.ShipStateDefend or ship.GetSoldierState() == States.ShipStateDefend:
				var discrete_position = Vector2(int(ship.global_position.x / BlocksSize),int(ship.global_position.y / BlocksSize))
				InternalGameState.AssignPositionToShip(ship,discrete_position)
				Defenders.append(ship)
				CurrentDefendersCount += 1
				continue
			Defenders.append(ship)
			CurrentDefendersCount += 1
			InternalGameState.AssignPositionToShip(ship,sectors_priority.Pop())
			InternalGameState.AssignShipState(ship,States.ShipStateDefend)
			pass
		pass
	pass

func ResolveSeekersConflict() -> void:
	if Seekers.size() - MinShipsSeekerCount < 0:
		var seekers_heap = SetSeekerPriority()
		var objetive_heap = SetSectorsPriority(PointObjetive)
		while Seekers.size() < MinShipsSeekerCount:
			if seekers_heap.Count() == 0 or objetive_heap.Length() == 0:
				break
			var ship = seekers_heap.Pop()
			Seekers.append(ship)
			InternalGameState.AssignPositionToShip(ship,objetive_heap.Pop())
			InternalGameState.AssignShipState(ship,States.ShipStateIdle)
			pass
		pass
	pass

func SetSectorsPriority(pos:Vector2) -> HeapMin:
	var heap = HeapMin.new()
	for sector in MapSectors:
		var vector_distance: Vector2 = sector - pos
		var distance = vector_distance.length_squared()
		heap.Push(sector,distance)
		pass
	return heap

func SetDefendersPriority() -> StrategyHeapMin:
	var heap = StrategyHeapMin.new()
	for ship in Allys:
		if not ship.GetSoldierState() == States.ShipStateDefend:
			var discrete_position = Vector2(int(ship.global_position.x / BlocksSize), int(ship.global_position.y / BlocksSize))
			var vector_distance: Vector2 = discrete_position - SelfFlagPosition
			var distance = vector_distance.length_squared()
			heap.Push(ship,distance)
			pass
		pass
	return heap

func SetSeekerPriority() -> StrategyHeapMin:
	var heap = StrategyHeapMin.new()
	for ship in InternalGameState.ShipsPositionsAssigned.keys():
		if ship in Defenders:
			continue
		var vector_distance: Vector2 = InternalGameState.ShipsPositionsAssigned[ship] - PointObjetive
		var distance = vector_distance.length_squared()
		heap.Push(ship,distance)
		pass
	return heap

func BuildMapSectors() -> void:
	var MapArea = GameMap.XSize() * GameMap.YSize()
	var sectors_area = MapArea / SectorsCount
	var sectors_dimentions = int(sqrt(sectors_area))
	if DefensiveRatio < sectors_dimentions:
		DefensiveRatio = sectors_dimentions
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

# AStar for the strategy
func GetStrategy(team:String) -> GameState:
	Seekers.clear()
	Defenders.clear()
	for ship in Allys:
		var discrete_position = Vector2(int(ship.global_position.x / BlocksSize), int(ship.global_position.y / BlocksSize))
		InternalGameState.AssignPositionToShip(ship,discrete_position)
		pass
	while not CheckConstraints(team):
		if not DefendersConstraints:
			ResolveDefendersConflicts()
			continue
		if not ShipsSeekerConstraint:
			ResolveSeekersConflict()
			continue
		if not SelfFlagAverageDistanceConstraint:
			ResolveAverageDistance(team)
			break
		pass
	return InternalGameState

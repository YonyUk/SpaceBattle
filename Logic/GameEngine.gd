extends Node

class_name GameEngine

var GameMap = Map.new()
var BLOCKS_SIZE = 0
var OFFSET_POSITION = Vector2()
var EnemyInstancer = null
var SoldierInstancer = null
var MaxSoldiers = 3
var WIDTH = 0
var HEIGHT = 0
var ROW_SECTORS = 10
var COLUMN_SECTORS = 10
var SECTORS_DIMENTIONS = 10
var VisionRange = 300
var PerceptionLatency = 25
var UserSoldiers = []
var EnemySoldiers = []
var FlagInstancer = null
var UserCommanderInstancer = null
var EnemyCommanderInstancer = null
var UserCommander = null
var EnemyCommander = null
var IDS = AreasIDS.new()
var SectorsCount = 0
var SoldiersLifePoints := 0
var SoldiersLowLimitLifePoints := 0
var SoldiersSaveDistance = 20
var FlagsPositions = {}

func LoadMap(path:String) -> Vector2:
	return GameMap.LoadMap(path)

func ExportMap(path: String,name: String) -> void:
	GameMap.ExportMap(path,name)
	pass

func SetSoldierSaveDistance(distance) -> void:
	SoldiersSaveDistance = distance
	pass

func SetSoldiersLowLimitLifePoints(value) -> void:
	SoldiersLowLimitLifePoints = value
	pass

func SetSoldiersLifePoints(value: int) -> void:
	SoldiersLifePoints = value
	pass

func SetMapParameters(blocks_size: int,offset_position: Vector2) -> void:
	BLOCKS_SIZE = blocks_size
	OFFSET_POSITION = offset_position
	pass

func SetFlagInstancer(instancer) -> void:
	FlagInstancer = instancer
	pass

func SetFlagPosition(team) -> Vector2:
	randomize()
	var x_limit_up = 0
	var x_limit_down = 0
	if team == IDS.UserTeam:
		x_limit_up = int(GameMap.XSize() / 4)
		x_limit_down = 0
		pass
	elif team == IDS.EnemyTeam:
		x_limit_up = GameMap.XSize()
		x_limit_down = int(GameMap.XSize() / 4) * 3
		pass
	var x_pos = int(rand_range(x_limit_down,x_limit_up))
	var y = int(rand_range(0,GameMap.YSize()))
	var pos = GameMap.GetFreeCellCloserTo(Vector2(x_pos,y))
	FlagsPositions[team] = pos
	return pos * BLOCKS_SIZE + OFFSET_POSITION

func SetFlag(team):
	var flag = null
	flag = FlagInstancer.instance()
	flag.SetTeam(team)
	if team == IDS.UserTeam:
		flag.SetFlagItem(IDS.BlueFlag)
		pass
	elif team == IDS.EnemyTeam:
		flag.SetFlagItem(IDS.RedFlag)
		pass
	flag.position = SetFlagPosition(team)
	return flag

func GetMapLimits():
	var x = COLUMN_SECTORS * SECTORS_DIMENTIONS
	var y = ROW_SECTORS * SECTORS_DIMENTIONS
	return Vector2(x,y) * BLOCKS_SIZE

func SetUserCommanderInstancer(instancer) -> void:
	UserCommanderInstancer = instancer
	pass

func SetEnemyCommanderInstancer(instancer) -> void:
	EnemyCommanderInstancer = instancer
	pass

func SetVisionRange(vision_range:int) -> void:
	VisionRange = vision_range
	pass

func SetPerceptionLatency(latency:int) -> void:
	PerceptionLatency = latency
	pass

func SetRowSectors(rows:int) -> void:
	ROW_SECTORS = rows
	if SectorsCount == 0:
		SectorsCount = rows * rows
		pass
	else:
		SectorsCount = min(SectorsCount,rows * rows)
		pass
	pass

func SetColumnSectors(columns:int) -> void:
	COLUMN_SECTORS = columns
	if SectorsCount == 0:
		SectorsCount = columns * columns
		pass
	else:
		SectorsCount = min(SectorsCount,columns * columns)
		pass
	pass

func SetSectorsDimentions(dimentions:int) -> void:
	SECTORS_DIMENTIONS = dimentions
	pass

func SetMaxSoldiers(max_soldiers: int) -> void:
	MaxSoldiers = max_soldiers
	pass

func SetEnemyInstancer(instancer) -> void:
	EnemyInstancer = instancer
	pass

func SetSoldierInstancer(instancer) -> void:
	SoldierInstancer = instancer
	pass

func CreateMap(row=10,col=10,sectors=10):
	GameMap.GenerateMap(row,col,sectors)
	pass

func GetPathTo(from:Vector2,to:Vector2) -> Array:
	return GameMap.GetPathTo(from,to)

func GetFreeMapPosition() -> Vector2:
	return GameMap.GetFreePosition()

func GetPlayerPosition() -> Vector2:
	return GameMap.GetFreeCellCloserTo(FlagsPositions[IDS.UserTeam]) * BLOCKS_SIZE + OFFSET_POSITION

# here we sets the soldiers around it's owns flag
func GenerateSoldiers(team:String) -> Array:
	var soldiers = []
	var bussy_cells := [FlagsPositions[team]]
	GameMap.SetBussyCells(bussy_cells)
	for i in range(MaxSoldiers):
		var pos = GameMap.GetFreeCellCloserTo(FlagsPositions[team])
		var soldier = null
		if team == IDS.UserTeam:
			soldier = SoldierInstancer.instance()
			UserSoldiers.append(soldier)
			pass
		elif team == IDS.EnemyTeam:
			EnemySoldiers.append(soldiers)
			soldier = EnemyInstancer.instance()
			pass
		soldier.SetSaveDistance(SoldiersSaveDistance)
		soldier.SetGameMap(GameMap)
		soldier.SetGameParameters(BLOCKS_SIZE,OFFSET_POSITION,self)
		soldier.SetLifePoints(SoldiersLifePoints)
		soldier.SetLowLimitLifePoints(SoldiersLowLimitLifePoints)
		soldier.SetFlagPosition(FlagsPositions[team])
		soldier.position = pos * BLOCKS_SIZE + OFFSET_POSITION
		soldier.SetTargetPosition(pos * BLOCKS_SIZE + OFFSET_POSITION)
		soldiers.append(soldier)
		var bussy_cells_soldier = soldier.GetBussyCells()
		GameMap.SetBussyCells(bussy_cells_soldier)
		bussy_cells += bussy_cells_soldier
		pass
	GameMap.FreeBussyCells(bussy_cells)
	return soldiers

func GenerateCommander(team:String,defensive_ratio: int):
	var bussy_cells := []
	var pos = GameMap.GetFreeCellCloserTo(FlagsPositions[team])
	var commander = null
	if team == IDS.UserTeam:
		commander = UserCommanderInstancer.instance()
		UserCommander = commander
		pass
	elif team == IDS.EnemyTeam:
		commander = EnemyCommanderInstancer.instance()
		EnemyCommander = commander
		pass
	commander.SetSaveDistance(SoldiersSaveDistance)
	commander.SetGameMap(GameMap)
	commander.SetGameParameters(BLOCKS_SIZE,OFFSET_POSITION,self)
	commander.SetLifePoints(SoldiersLifePoints)
	commander.SetLowLimitLifePoints(SoldiersLowLimitLifePoints)
	commander.SetFlagPosition(FlagsPositions[team])
	commander.position = pos * BLOCKS_SIZE + OFFSET_POSITION
	commander.SetSectorsCount(SectorsCount)
	commander.SetDefensiveRatio(defensive_ratio)
	commander.SetTargetPosition(pos * BLOCKS_SIZE + OFFSET_POSITION)
	return commander

func VisionCollide(from:Vector2,to:Vector2) -> bool:
	var result = false
	var discrete_from = Vector2(int(from.x / BLOCKS_SIZE),int(from.y / BLOCKS_SIZE))
	var discrete_to = Vector2(int(to.x / BLOCKS_SIZE),int(to.y / BLOCKS_SIZE))
	if abs(discrete_from.x - discrete_to.x) == 0:
		for i in range(min(discrete_from.y,discrete_to.y),max(discrete_from.y,discrete_to.y)):
			if GameMap.IsBlock(Vector2(discrete_from.x,i)):
				result = true
			pass
		pass
	else:
		var vector = from - to
		var pendient = vector.y / vector.x
		var offset = from.y - pendient * from.x
		var cells_visited = []
		var discrete_vector = discrete_from - discrete_to
		var x_diferencial = max(abs(discrete_vector.x),abs(discrete_vector.y))
		var x_increment = abs(int(vector.x)) / x_diferencial
		for x in range(min(from.x,to.x),max(from.x,to.x),x_increment):
			var y = x*pendient + offset
			var pos = Vector2(int(x / BLOCKS_SIZE),int(y / BLOCKS_SIZE))
			cells_visited.append(cells_visited)
			if not pos in cells_visited and GameMap.IsBlock(pos):
				result = true
				break
			pass
		pass
	return result

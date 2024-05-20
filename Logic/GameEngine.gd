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
var UserCommanderInstancer = null
var EnemyCommanderInstancer = null
var UserCommander = null
var EnemyCommander = null
var IDS = AreasIDS.new()

func SetMapParameters(blocks_size: int,offset_position: Vector2) -> void:
	BLOCKS_SIZE = blocks_size
	OFFSET_POSITION = offset_position
	pass

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
	pass

func SetColumnSectors(columns:int) -> void:
	COLUMN_SECTORS = columns
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

func GenerateSoldiers(team:String) -> Array:
	var soldiers = []
	var bussy_cells := []
	for i in range(MaxSoldiers):
		var pos = GetFreeMapPosition()
		var soldier = null
		if team == IDS.UserTeam:
			soldier = SoldierInstancer.instance()
			UserSoldiers.append(soldier)
			pass
		elif team == IDS.EnemyTeam:
			EnemySoldiers.append(soldiers)
			soldier = EnemyInstancer.instance()
			pass
		soldier.SetGameMap(GameMap)
		soldier.SetGameParameters(BLOCKS_SIZE,OFFSET_POSITION,self)
		soldier.position = pos * BLOCKS_SIZE + OFFSET_POSITION
		# this lines are temporaly
		pos = GetFreeMapPosition()
		soldier.SetTargetPosition(pos * BLOCKS_SIZE + OFFSET_POSITION)
		# ends
		soldiers.append(soldier)
		var bussy_cells_soldier = soldier.GetBussyCells()
		GameMap.SetBussyCells(bussy_cells_soldier)
		bussy_cells += bussy_cells_soldier
		pass
	GameMap.FreeBussyCells(bussy_cells)
	return soldiers

func GenerateCommander(team:String):
	var bussy_cells := []
	var pos = GetFreeMapPosition()
	var commander = null
	if team == IDS.UserTeam:
		commander = UserCommanderInstancer.instance()
		UserCommander = commander
		pass
	elif team == IDS.EnemyTeam:
		commander = EnemyCommanderInstancer.instance()
		EnemyCommander = commander
		pass
	commander.SetGameMap(GameMap)
	commander.SetGameParameters(BLOCKS_SIZE,OFFSET_POSITION,self)
	commander.position = pos * BLOCKS_SIZE + OFFSET_POSITION
	# this lines are temporaly
	pos = GetFreeMapPosition()
	commander.SetTargetPosition(pos * BLOCKS_SIZE + OFFSET_POSITION)
	# ends
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

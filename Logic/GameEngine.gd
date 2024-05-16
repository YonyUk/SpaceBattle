extends Node

class_name GameEngine

var GameMap = Map.new()
var BLOCKS_SIZE = 0
var OFFSET_POSITION = Vector2()

func SetMapParameters(blocks_size: int,offset_position: Vector2) -> void:
	BLOCKS_SIZE = blocks_size
	OFFSET_POSITION = offset_position
	pass

func CreateMap(row=10,col=10,sectors=10):
	GameMap.GenerateMap(row,col,sectors)
	pass

func GetPathTo(from:Vector2,to:Vector2) -> Array:
	return GameMap.GetPathTo(from,to)

func GetFreeMapPosition() -> Vector2:
	return GameMap.GetFreePosition()

func GenerateSoldiers(max_soldiers: int,blocks_size: int,offset_positions: Vector2,EnemyInstancer,map:Map) -> Array:
	var soldiers = []
	var bussy_cells := []
	for i in range(max_soldiers):
		var pos = GetFreeMapPosition()
		var soldier = EnemyInstancer.instance()
		soldier.SetGameMap(map)
		soldier.SetGameParameters(blocks_size,offset_positions,self)
		soldier.position = pos * blocks_size + offset_positions
		pos = GetFreeMapPosition()
		soldier.SetTargetPosition(pos * blocks_size + offset_positions)
		soldiers.append(soldier)
		var bussy_cells_soldier = soldier.GetBussyCells()
		GameMap.SetBussyCells(bussy_cells_soldier)
		bussy_cells += bussy_cells_soldier
		pass
	GameMap.FreeBussyCells(bussy_cells)
	return soldiers

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

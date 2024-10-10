extends Node

class_name Map
# this class represent a bidimensional map

# graph that represents the paths of this map
var Generator = MapGenerator.new()
var Heap = HeapMin.new()

# boolean map that represents this map
var map := []
var bussy_cells := []
var SIZE := Vector2()

func GenerateMap(row_sectors,column_sectors,sectors_dimension) -> Array:
	map = Generator.get_map_formatted(row_sectors,column_sectors,sectors_dimension)
	return map

func ExportMap(path: String,name: String) -> void:
	var file = File.new() 
	var file_path = path + '/' + name + '.json'
	var blocks = []
	for i in range(XSize()):
		for j in range(YSize()):
			if IsBlock(Vector2(i,j)):
				blocks.append(Vector2(i,j))
				pass
			pass
		pass
	var json_data = JSON.print(blocks)
	file.open(file_path,File.WRITE)
	file.store_string(json_data)
	file.close()
	pass

func LoadMap(path:String) -> Vector2:
	var file = File.new()
	file.open(path,File.READ)
	var data = file.get_as_text()
	var parse_data = parse_json(data)
	var x_size = parse_data['size'][0]
	var y_size = parse_data['size'][1]
	SIZE = Vector2(x_size,y_size)
	var result = []
	for i in range(x_size):
		var row = []
		for j in range(x_size):
			row.append(true)
			pass
		result.append(row)
		pass
	for cell in parse_data['cells']:
		result[cell[1]][cell[0]] = false
		pass
	map = result
	return Vector2(int(x_size / 10),int(y_size / 10))

func SetBussyCells(cells: Array) -> void:
	bussy_cells += cells
	pass

func FreeBussyCells(cells:Array) -> void:
	while cells.size() > 0:
		var cell = cells.pop_front()
		if cell in bussy_cells:
			var index = bussy_cells.find(cell)
			bussy_cells.pop_at(index)
			pass
		pass
	pass

func IsBlock(pos:Vector2) -> bool:
	if pos.x > XSize() - 1 or pos.y > YSize() - 1:
		return false
	if pos in bussy_cells:
		return true
	return not map[pos.y][pos.x]

func XSize() -> int:
	return map[0].size()

func YSize() -> int:
	return map.size()

func GetFreePosition() -> Vector2:
	var x = int(rand_range(0,map[0].size()))
	var y = int(rand_range(0,map.size()))
	var pos = Vector2(x,y)
	if IsBlock(pos):
		GetFreeCellCloserTo(pos)
		pass
	return pos

# BFS
func GetFreeCellCloserTo(pos:Vector2) -> Vector2:
	if pos.x < 0:
		pos = Vector2(0,pos.y)
		pass
	elif pos.x > XSize() - 1:
		pos = Vector2(XSize() - 1,pos.y)
		pass
	
	if pos.y < 0:
		pos = Vector2(pos.x,0)
		pass
	elif pos.y > YSize() - 1:
		pos = Vector2(pos.x,YSize() - 1)
		pass
	pos = Vector2(min(map[0].size() - 1,pos.x),min(map.size() - 1,pos.y))
	if map[pos.y][pos.x] and not pos in bussy_cells:
		return pos
	var directions = [-1,0,1]
	var visited = []
	var queue = [pos]
	while not map[pos.y][pos.x] or pos in bussy_cells:
		var cell = queue.pop_front()
		for i in range(directions.size()):
			for j in range(directions.size()):
				var neigborgh = Vector2(directions[i],directions[j]) + cell
				if not IsInRange(neigborgh.x,neigborgh.y) or neigborgh in visited:
					continue
				queue.push_back(neigborgh)
				pass
			pass
		if not cell in visited:
			visited.append(cell)
			pass
		pos = queue[0]
		pass
	return pos

func EuclidianDistance(pos0: Vector2, pos1: Vector2) -> float:
	return (pos1 - pos0).length_squared()

func ManhatanDistance(pos0:Vector2,pos1:Vector2) -> float:
	var distance = pos1 - pos0
	return abs(distance.x) + abs(distance.y)

func IsInRange(x: int,y: int) -> bool:
	if x < 0 or y < 0 or x > map[0].size() - 1 or y > map.size() - 1:
		return false
	return true 

func Neighborgs(pos: Vector2) -> Array:
	var result = []
	var dir_x = [0,1,0,-1]
	var dir_y = [-1,0,1,0]
	for i in range(dir_x.size()):
		var pos_1 = Vector2(dir_x[i],dir_y[i]) + pos
		if IsInRange(pos_1.x,pos_1.y) and map[pos_1.y][pos_1.x] and not pos_1 == pos and not pos_1 in bussy_cells:
			result.append(pos_1)
			pass
		pass
	return result

func NormalizePath(path:Array) -> Array:
	if path.size() == 0:
		return path
	var result = [path.pop_back()]
	while path.size() > 0:
		var cell = path.pop_back()
		if ManhatanDistance(cell,result[0]) < 2:
			result.push_front(cell)
			pass
		pass
	return result

# this is an implementation of the AStar algorithm
func GetPathTo(from:Vector2,to:Vector2) -> Array:
	var result = []
	var visited = []
	Heap.Clear()
	Heap.Push(from,EuclidianDistance(from,to))
	
	var pos = from
	while Heap.Length() > 0 and not pos == to:
		pos = Heap.Pop()
		visited.append(pos)
		result.append(pos)
		var neighborgs = Neighborgs(pos)
		for n in neighborgs:
			if not n in visited:
				Heap.Push(n,EuclidianDistance(n,to))
				pass
			pass
		pass
	return NormalizePath(result)

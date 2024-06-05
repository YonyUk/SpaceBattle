extends Node

class_name Soldier

var TargetPosition := Vector2()
var TargetDestination = null
var FlankPath = null
var StateMoving = false
var StateDefending = false
var back = 0
var backLeft = 1
var left = 2
var frontLeft = 3
var frontRight = 4
var right = 5
var backRight = 6
var PathToTargetPosition := []
var BLOCKS_SIZE = 1
var OFFSET_POSITION = Vector2()
var LifePoints := 0
var MaxLifePoints := 0
var DefendingPosition = null
var TargetEnemy = null
var SelfFlagPosition := Vector2()
var DefensivePerimeter = 10
var GameMap = null

func SetMaxLifePoints(value: int) -> void:
	MaxLifePoints = value
	pass

func ApplyDamage(damage: int) -> void:
	LifePoints -= damage
	pass

func Health(value: float) -> void:
	if LifePoints < MaxLifePoints:
		LifePoints += value
		pass
	if LifePoints > MaxLifePoints:
		LifePoints = MaxLifePoints
		pass
	pass

func SetDefensivePerimeter(distance: int) -> void:
	DefensivePerimeter = distance
	pass

func SetStateDefending(value: bool) -> void:
	StateDefending = value
	pass

func SetFlagPosition(pos:Vector2) -> void:
	SelfFlagPosition = pos
	pass

func SetTargetEnemy(enemy) -> void:
	TargetEnemy = enemy
	pass

func SetDefendingPosition(pos:Vector2) -> void:
	DefendingPosition = pos
	pass

func SetLifePoints(points:int) -> void:
	LifePoints = points
	pass

func SetGameParameters(blocks_size: int, offset_position: Vector2) -> void:
	BLOCKS_SIZE = blocks_size
	OFFSET_POSITION = offset_position
	pass

func Flank(collisionDetector: SoldierItem,vision_range:float,map:Map):
	SetTargetPosition(collisionDetector.GetFlankPosition(),collisionDetector.global_position,vision_range,map)
	pass

func CollapseDiagonalsMovments(path:Array,map:Map) -> Array:
	if path.size() == 0:
		return path
	var result = [path[0]]
	var i = 0
	var j = 0
	while i < path.size() and j < path.size():
		j  = i + 1
		while j < path.size():
			if (j - i) % 2 == 0:
				var neig = map.Neighborgs(path[j])
				if neig.size() == 4 and IsDiagonalTo(path[i],path[j]):
					j += 2
					if j >= path.size():
						result.append(path[path.size() - 1])
						break
					pass
				else:
					result.append(path[j - 2])
					result.append(path[j - 1])
					i = j
					break
				pass
			else:
				j += 1
				pass
			pass
		if j < path.size():
			result.append(path[j])
			pass
		pass
	return result

func IsDiagonalTo(pos0:Vector2,pos1:Vector2):
	var temp = pos0 - pos1
	if abs(temp.x) == abs(temp.y):
		return true
	return false

func GetTargetPosition() -> Vector2:
	if FlankPath:
		return FlankPath
	if PathToTargetPosition.size() > 0 and PathToTargetPosition[0]:
		var result = PathToTargetPosition[0]
		return result * BLOCKS_SIZE + OFFSET_POSITION
	if TargetEnemy:
		return TargetEnemy.global_position
	return TargetPosition

func NormalizeTargetPosition(pos:Vector2):
	var temp = Vector2(int(pos.x / BLOCKS_SIZE), int(pos.y / BLOCKS_SIZE))
	return temp * BLOCKS_SIZE + OFFSET_POSITION

func SetMarkerPositions(from:Vector2,to:Vector2,map:Map):
	clamp(to.x,0,BLOCKS_SIZE * map.XSize())
	clamp(to.y,0,BLOCKS_SIZE * map.YSize())
	var discrete_from = Vector2(int(from.x / BLOCKS_SIZE),int(from.y / BLOCKS_SIZE))
	var discrete_to = Vector2(int(to.x / BLOCKS_SIZE), int(to.y / BLOCKS_SIZE))
	discrete_from = map.GetFreeCellCloserTo(discrete_from)
	discrete_to = map.GetFreeCellCloserTo(discrete_to)
	var path_points = map.GetPathTo(discrete_from,discrete_to)
	path_points = CollapseDiagonalsMovments(path_points,map)
	PathToTargetPosition = GetMarkerPoints(path_points)
	pass

func GetMarkerPoints(path: Array) -> Array:
	if path.size() == 0:
		return path
	var result = []
	var last_point = path.pop_front()
	var x_move = false
	var y_move = false
	for point in path:
		if not point.x == last_point.x:
			if not x_move:
				result.append(last_point)
				x_move = true
				y_move = false
				pass
			pass
		if not point.y == last_point.y:
			if not y_move:
				result.append(last_point)
				y_move = true
				x_move = false
				pass
			pass
		last_point = point
		pass
	result.append(path.pop_back())
	return result

func SetTargetPosition(pos:Vector2,current_position:Vector2,vision_range:float,map:Map) -> void:
	TargetDestination = pos
	var distance = sqrt((TargetDestination - current_position).length_squared())
	if  distance > vision_range:
		var temp = TargetDestination - current_position
		var sections = Vector2(int(temp.x / vision_range),int(temp.y / vision_range))
		var x = temp.x
		var y = temp.y
		if not sections.x == 0:
			x = int(temp.x / abs(sections.x))
			pass
		if not sections.y == 0:
			y = int(temp.y / abs(sections.y))
			pass
		TargetPosition = Vector2(x,y) + current_position
		pass
	else:
		TargetPosition = NormalizeTargetPosition(TargetDestination)
		TargetDestination = null
		pass
	SetMarkerPositions(current_position,TargetPosition,map)
	StateMoving = true
	pass

func TargetPositionReached(current_position:Vector2,vision_range:float,map:Map):
	if FlankPath:
		FlankPath = null
		pass
	if TargetDestination or PathToTargetPosition.size() > 0:
		if PathToTargetPosition.size() > 0:
			PathToTargetPosition.pop_front()
			pass
		else:
			SetTargetPosition(TargetDestination,current_position,vision_range,map)
			pass
		pass
	else:
		StateMoving = false
		pass
	pass

extends Area2D

class_name VisualEnemy

onready var soldierItem = $EnemyItem
onready var Body = $Body
onready var VisionRange = sqrt(($EnemyItem/ShipDirector.global_position - global_position).length_squared())
onready var Radar = $ShipRadar

var GAME_ENGINE = null
var GameMap = null
var label = null
var IDS = AreasIDS.new()
var Core = Soldier.new()
var Speed = 2
var Movement := Vector2()
var OnPosition = false
var TargetPosition = Vector2()
var ID = IDS.SoldierID
var TEAM = IDS.EnemyTeam
var ShipsCollision = true
var BLOCKS_SIZE = 1
var OFFSET_POSITION = Vector2()
var VISION_SCALE = 300

## New changes

func SetMapLimits(size:Vector2) -> void:
	pass

## Here ends the changes

func SetGameParameters(blocks_size:int,offset_position: Vector2,game_engine) -> void:
	BLOCKS_SIZE = blocks_size
	OFFSET_POSITION = offset_position
	GAME_ENGINE = game_engine
	Core.SetGameParameters(BLOCKS_SIZE,OFFSET_POSITION)
	pass

func SetGameMap(map:Map):
	GameMap = map
	pass

func SetVisionRange(vision_range:float=300) -> void:
	Radar = $ShipRadar
	VisionRange = vision_range
	Radar.scale = Vector2(VisionRange / VISION_SCALE,VisionRange / VISION_SCALE)
	pass

func AutoSetVisionRange() -> void:
	Radar = $ShipRadar
	VisionRange = sqrt(($EnemyItem/ShipDirector.global_position - global_position).length_squared())
	Radar.scale = Vector2(VisionRange / VISION_SCALE,VisionRange / VISION_SCALE)
	pass

func ShipColisionEnable() -> void:
	ShipsCollision = true
	pass

func ShipCollisionDisable() -> void:
	ShipsCollision = false
	pass

func SetTargetPosition(pos:Vector2) -> void:
	TargetPosition = pos
	if not VisionRange:
		SetVisionRange()
		pass
	Core.SetTargetPosition(pos,global_position,VisionRange,GameMap)
	OnPosition = false
	pass

func RotateSoldierItem(vector: Vector2) -> void:
	if vector.length_squared() > 0:
		rotation = vector.angle() + PI / 2
		pass
	pass

func MakeActions() -> void:
	if Core.StateMoving:
		Move()
		pass
	elif global_position == TargetPosition:
		OnPosition = true
		pass
	else:
		SetTargetPosition(TargetPosition)
		pass
	pass

func FixMovement():
	var motion = Vector2()
	var destination = Core.GetTargetPosition()
	var current_pos = global_position
	if destination.x > global_position.x:
		motion.x += 1
		pass
	elif destination.x < global_position.x:
		motion.x -= 1
		pass
	if destination.y > global_position.y:
		motion.y += 1
		pass
	elif destination.y < global_position.y:
		motion.y -= 1
		pass
	
	if motion.x == 0 and motion.y == 0:
		Core.TargetPositionReached(global_position,VisionRange,GameMap)
		pass
	else:
		global_position += motion
		pass
	pass

func Move():
	Movement = Core.GetTargetPosition() - global_position
	RotateSoldierItem(Movement)
	translate(Movement.normalized() * Speed)
	global_position = Vector2(int(global_position.x),int(global_position.y))
	if Movement.length_squared() < 5:
		FixMovement()
		pass
	pass

func GetBussyCells():
	var result := []
	var directions = [-1,0,1]
	var discrete_position = Vector2(int(global_position.x / BLOCKS_SIZE),int(global_position.y / BLOCKS_SIZE))
	for i in range(directions.size()):
		for j in range(directions.size()):
			var pos = discrete_position + Vector2(directions[i],directions[j])
			if GameMap.IsInRange(pos.x,pos.y):
				result.append(pos)
				pass
			pass
		pass
	return result

func _physics_process(delta):
	MakeActions()
	pass

func _on_VisualEnemy_body_entered(body):
	var bussy_cells = []
	if body.ID == IDS.UserID:
		bussy_cells = body.GetBussyCells()
		GameMap.SetBussyCells(bussy_cells)
		pass
	Core.Flank(soldierItem,VisionRange,GameMap)
	GameMap.FreeBussyCells(bussy_cells)
	pass # Replace with function body.

func _on_VisualEnemy_area_entered(area):
	if ShipsCollision and area.ID == IDS.SoldierID and area > self:
		var bussy_cells = area.GetBussyCells()
		var my_bussy_cells = GetBussyCells()
		GameMap.SetBussyCells(bussy_cells)
		SetTargetPosition(TargetPosition)
		GameMap.FreeBussyCells(bussy_cells)
		pass
	pass # Replace with function body.

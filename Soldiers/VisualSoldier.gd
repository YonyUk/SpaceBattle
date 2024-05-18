extends Area2D

class_name VisualSoldier

onready var soldierItem = $SoldierItem
onready var Body = $Body
onready var Shooter = $Shooter
onready var ShooterTimer = $ShootingTimer
onready var Radar = $ShipRadar

var VisionRange = 300
var GameMap = null
var GAME_ENGINE = null
var label = null
var IDS = AreasIDS.new()
var Core = Soldier.new()
var Speed = 2
var Movement := Vector2()
var OnPosition = false
var TargetPosition = Vector2()
var ID = IDS.SoldierID
var TEAM = IDS.UserTeam
var ShipsCollision = true
var BLOCKS_SIZE = 1
var OFFSET_POSITION = Vector2()
var VISION_SCALE = 300

# Control variables
var selfFlagPosition = Vector2()
var Perception = SoldierAgentPerception.new()
var Brain = Predicates.new()
var EnemysSeen = []
var Shooting = true
# Methods for the game

func See() -> void:
	Perception.SetLifePoints(Core.LifePoints)
	Perception.SetEnemysSeen(EnemysSeen)
	Perception.SetCurrentPosition(global_position)
	Perception.SetTargetPosition(TargetPosition)
	var enemy_seen = EnemySeen()
	Perception.SetCanRotate(enemy_seen[0])
	
	if enemy_seen[0]:
		Perception.SetEnemyDetected(enemy_seen[1])
		pass
	if Core.DefendingPosition:
		Perception.SetDefending(true)
		pass
	else:
		Perception.SetDefending(false)
		pass
	if Core.TargetEnemy:
		Perception.SetStateAttacking(true)
		pass
	else:
		Perception.SetStateAttacking(false)
		pass
	pass

func SetMapLimits(size:Vector2) -> void:
	Shooter.SetMapLimits(size)
	pass

func Shoot() -> void:
	Shooting = false
	var bullet = Shooter.Shoot(TEAM)
	bullet.rotation = rotation
	get_tree().current_scene.AddBullet(bullet)
	pass

func RotateToEnemy(enemy) -> void:
	var vector = enemy.global_position - global_position
	rotation = vector.angle() + PI / 2
	pass

func GetCurrentState() -> void:
	Brain.SoldierReasoning(Perception)
	pass

func SetAttackTarget(enemy) -> void:
	Core.SetTargetEnemy(enemy)
	pass

func SetDefendingPosition(pos:Vector2) -> void:
	Core.SetDefendingPosition(pos)
	pass

func SetFlagPosition(pos:Vector2) -> void:
	Core.SetFlagPosition(pos)
	pass

func SetLifePoints(points:int) -> void:
	Core.SetLifePoints(points)
	pass

func EnemySeen() -> Array:
	var result = [false,null]
	for enemy in EnemysSeen:
		if CanSeeToTarget(enemy):
			return [true,enemy]
		pass
	return result

func GetEnemysSeen() -> Array:
	return EnemysSeen

func CanSeeToTarget(target) -> bool:
	return not GAME_ENGINE.VisionCollide(global_position,target.global_position)
# here ends the changes #################

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
	Radar.scale = Vector2(vision_range / VISION_SCALE,vision_range / VISION_SCALE)
	pass

func AutoSetVisionRange() -> void:
	Radar = $ShipRadar
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
	Perception.SetStateMoving(Core.StateMoving)
	# Moving Actions
	if Perception.Moving():
		Move()
		pass
	elif global_position == TargetPosition:
		OnPosition = true
		pass
	else:
		SetTargetPosition(TargetPosition)
		pass
	
	# RotateActions
	if Perception.CanRotate():
		if Shooting:
			ShooterTimer.start()
			Shooting = false
			pass
		var vector_to_target = Perception.EnemySeen().global_position - global_position
		rotation = vector_to_target.angle() + PI / 2
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
	See()
	GetCurrentState()
	MakeActions()
	pass

func _on_VisualSoldier_body_entered(body):
	var bussy_cells = []
	if body.ID == IDS.UserID:
		bussy_cells = body.GetBussyCells()
		GameMap.SetBussyCells(bussy_cells)
		pass
	Core.Flank(soldierItem,VisionRange,GameMap)
	GameMap.FreeBussyCells(bussy_cells)
	pass # Replace with function body.

func _on_VisualSoldier_area_entered(area):
	var IsShip = area.ID == IDS.SoldierID or area.ID == IDS.CommandID
	if ShipsCollision and IsShip and area > self:
		var bussy_cells = area.GetBussyCells()
		GameMap.SetBussyCells(bussy_cells)
		SetTargetPosition(TargetPosition)
		GameMap.FreeBussyCells(bussy_cells)
		pass
	pass # Replace with function body.

func _on_ShipRadar_ShipDetected(ship):
	if not ship == self and not ship == soldierItem and ship.TEAM == IDS.EnemyTeam:
		EnemysSeen.append(ship)
		pass
	pass # Replace with function body.

func _on_ShipRadar_ShipRadarExited(ship):
	if ship in EnemysSeen:
		var index = EnemysSeen.find(ship)
		EnemysSeen.pop_at(index)
		pass
	pass # Replace with function body.

func _on_ShootingTimer_timeout():
	if Perception.CanShoot():
		Shoot()
		pass
	Shooting = true
	pass # Replace with function body.

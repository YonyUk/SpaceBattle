extends Area2D

class_name VisualSoldier

onready var soldierItem = $SoldierItem
onready var Body = $Body
onready var Shooter = $Shooter
onready var ShooterTimer = $ShootingTimer
onready var Radar = $ShipRadar
onready var Explosion = preload("res://Explosions/ShipExplosion.tscn")

var VisionRange = 300
var GameMap = null
var GAME_ENGINE = null
var label = null
var IDS = AreasIDS.new()
var Core = Soldier.new()
var Speed = 2
var CurrentSpeed = Speed
var AutoDefendingSpeed = Speed * 2
var Movement := Vector2()
var OnPosition = false
var TargetPosition = Vector2()
var ID = IDS.SoldierID
var TEAM = IDS.UserTeam
var ShipsCollision = true
var BLOCKS_SIZE = 1
var OFFSET_POSITION = Vector2()
var VISION_SCALE = 300
var PerceptionLatency = 1
var PerceptionRate = 0
var Active = false

# Control variables
var selfFlagPosition = Vector2()
var Perception = SoldierAgentPerception.new()
var Brain = Predicates.new()
var EnemysSeen = []
var Shooting = true
var SectorsCount = 0
var States = ShipStates.new()
var SaveDistance = 20
var AutoDefendingIn = false
var LifePoints = 0
var EnemyFlagFound = false
var EnemyFlagPosition = Vector2()
var bulletsSeen := []
var Shooted = false
var ShootedTimer = 500
var CurrentShootedTime = ShootedTimer

# Methods for the game

func _ready():
	pass

func WasShooted() -> bool:
	return Shooted

func SetSaveDistance(distance) -> void:
	SaveDistance = distance
	pass

func Destroy(damage: int) -> void:
	Shooted = true
	CurrentShootedTime = ShootedTimer
	Core.ApplyDamage(damage)
	if Core.LifePoints <= 0:
		Shooted = false
		var explosion = Explosion.instance()
		explosion.global_position = global_position
		get_tree().current_scene.AddExplosion(explosion)
		call_deferred("SelfDelete")
		pass
	pass

func SelfDelete() -> void:
	if get_tree():
		get_tree().current_scene.DeleteShip(self,TEAM)
		pass
	pass

func SetDefensiveDistance(distance: float) -> void:
	Perception.SetDefendingDistance(distance)
	pass

func SetSoldierState(state: int) -> void:
	if state == States.ShipStateDefend:
		Perception.SetDefending(true)
		pass
	else:
		Perception.SetDefending(false)
		pass
	pass

func SetSectorsCount(count: int) -> void:
	SectorsCount = count
	pass

func GetSoldierState() -> int:
	if Perception.Defending():
		return States.ShipStateDefend
	if Perception.AutoDefending():
		return States.ShipStateAutoDefend
	if Perception.Attacking():
		return States.ShipsStateAttacking
	return States.ShipStateIdle

func GetDefendingPosition() -> Vector2:
	return Core.DefendingPosition

func See() -> void:
	Perception.SetLifePoints(Core.LifePoints)
	Perception.SetLowLimitLifePoints(Core.LowLimitLifePoints)
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
	selfFlagPosition = pos * BLOCKS_SIZE + OFFSET_POSITION
	pass

func SetLifePoints(points:int) -> void:
	Core.SetMaxLifePoints(points)
	Core.SetLifePoints(points)
	LifePoints = points
	pass

func SetLowLimitLifePoints(value) -> void:
	Core.SetLowLimitLifePoints(value)
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

func SetPerceptionLatency(latency:int = 1) -> void:
	PerceptionLatency = latency
	pass

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

func GetEnemyDistance(enemy) -> float:
	var vector_distance: Vector2 = enemy.global_position - global_position
	var result = sqrt(vector_distance.length_squared())
	return result

func MakeActions() -> void:
	Perception.SetStateMoving(Core.StateMoving)
	var can_move = false
	#Offensive Actions
	if Perception.Attacking():
		var enemy = EnemySeen()[1]
		SetAttackTarget(enemy)
		if enemy and GetEnemyDistance(enemy) > SaveDistance:
			can_move = true
			pass
		pass
	else:
		SetAttackTarget(null)
		pass
	
	#AutoDefending
	if Perception.AutoDefending():
		SetTargetPosition(selfFlagPosition)
		pass
	
	# Moving Actions
	if Perception.Moving():
		if Perception.Attacking():
			if can_move:
				Move()
				pass
			pass
		else:
			Move()
			pass
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
		var target = Perception.EnemySeen()
		var vector_to_target = target.global_position - global_position
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
	translate(Movement.normalized() * CurrentSpeed)
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
	if CurrentShootedTime > 0:
		CurrentShootedTime -= 1
		pass
	else:
		Shooted = false
		pass
	Core.Health(1)
	if PerceptionRate == PerceptionLatency:
		See()
		GetCurrentState()
		Core.SetStateDefending(Perception.Defending())
		PerceptionRate = 0
		pass
	PerceptionRate += 1
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
	pass

func _on_ShipRadar_ShipDetected(ship):
	if not ship == self and not ship == soldierItem and not ship.TEAM == TEAM and not ship.ID == IDS.BulletID:
		EnemysSeen.append(ship)
		pass
	if not ship == self and not ship == soldierItem and ship.ID == IDS.BulletID:
		bulletsSeen.append([ship,ship.global_position])
		pass
	if ship.ID == IDS.FlagID and not ship.TEAM == TEAM:
		EnemyFlagFound = true
		EnemyFlagPosition = Vector2(int(ship.global_position.x / BLOCKS_SIZE),int(ship.global_position.y / BLOCKS_SIZE))
		pass
	pass # Replace with function body.

func _on_ShipRadar_ShipRadarExited(ship):
	if ship in EnemysSeen:
		var index = EnemysSeen.find(ship)
		EnemysSeen.pop_at(index)
		pass
	else:
		for i in range(bulletsSeen.size()):
			if bulletsSeen[i][0] == ship:
				bulletsSeen.pop_at(i)
				break
			pass
		pass
	pass # Replace with function body.

func _on_ShootingTimer_timeout():
	if Perception.CanShoot():
		Shoot()
		pass
	Shooting = true
	pass # Replace with function body.

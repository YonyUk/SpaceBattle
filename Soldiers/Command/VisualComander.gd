extends VisualSoldier

onready var LeftShooter = $LeftShooter
onready var RightShooter = $RightShooter
onready var CenterShooter = $CenterShooter

var Subordinades = []
var TotalEnemysSeen = []
var StrategyBrain = CommanderBrain.new()
var DefensiveRatio = 500
var ReasoningLatency = 10
var ReasoningTimer = 0
var DefensivePerimeter = 5

func _ready():
	soldierItem = $CommandItem
	Speed = Speed / 2 
	Subordinades = get_tree().current_scene.GetSubordinades(TEAM)
	Subordinades.append(self)
	selfFlagPosition = get_tree().current_scene.GetFlagPosition(TEAM)
	StrategyBrain.SetTeam(TEAM)
	StrategyBrain.SetBlocksSize(BLOCKS_SIZE)
	StrategyBrain.SetDefensiveRatio(DefensiveRatio)
	StrategyBrain.SetOffsetPosition(OFFSET_POSITION)
	StrategyBrain.SetGameMap(GameMap)
	StrategyBrain.SetSectorsCount(SectorsCount)
	StrategyBrain.SetGameState(int(Subordinades.size() / 3),selfFlagPosition,Subordinades,TEAM)
	StrategyBrain.BuildMapSectors()
	var enemys = get_tree().current_scene.GetSubordinades(IDS.EnemyTeam)
	StrategyBrain.SetEnemys(IDS.EnemyTeam,enemys)
	var flag_enemy_position = get_tree().current_scene.GetFlagPosition(IDS.EnemyTeam)
	StrategyBrain.SetObjetivePoint(flag_enemy_position)
	SetLifePoints(Core.LifePoints * 10)
	LeftShooter.SetDamage(300)
	CenterShooter.SetDamage(300)
	RightShooter.SetDamage(300)
	pass

func SetDefensivePerimeter(perimeter: int) -> void:
	DefensivePerimeter = perimeter
	pass

func Shoot() -> void:
	Shooting = false
	var leftBullet = LeftShooter.Shoot(TEAM)
	var rightBullet = RightShooter.Shoot(TEAM)
	var centerBullet = CenterShooter.Shoot(TEAM)
	leftBullet.rotation = rotation
	rightBullet.rotation = rotation
	centerBullet.rotation = rotation
	get_tree().current_scene.AddBullet(leftBullet)
	get_tree().current_scene.AddBullet(rightBullet)
	get_tree().current_scene.AddBullet(centerBullet)
	pass

func SetReasoningLatency(latency: int) -> void:
	ReasoningLatency = latency
	pass

func SetDefensiveRatio(ratio: int) -> void:
	DefensiveRatio = ratio
	pass

func SetMapLimits(size:Vector2) -> void:
	LeftShooter.SetMapLimits(size)
	RightShooter.SetMapLimits(size)
	CenterShooter.SetMapLimits(size)
	pass

func GetCurrentEnemys(team: String) -> Array:
	var enemys = []
	for ally in Subordinades:
		for ship in ally.EnemysSeen:
			if not ship in enemys:
				enemys.append(ship)
				pass
			pass
		pass
	return enemys

func _physics_process(delta):
	._physics_process(delta)
	Subordinades = get_tree().current_scene.GetSubordinades(TEAM)
	Subordinades.append(self)
	StrategyBrain.SetAllys(Subordinades)
	var enemys = GetCurrentEnemys(IDS.EnemyTeam)
	
	if ReasoningTimer == ReasoningLatency:
		StrategyBrain.SetMinDefenders(int(Subordinades.size() / 3))
		StrategyBrain.SetMinSeekers(int(Subordinades.size() / 4))
		StrategyBrain.SetEnemys(IDS.EnemyTeam,enemys)
		var strategy = StrategyBrain.GetStrategy(IDS.EnemyTeam)
		for ship in strategy.ShipsPositionsAssigned.keys():
			ship.SetTargetPosition(strategy.ShipsPositionsAssigned[ship] * BLOCKS_SIZE + OFFSET_POSITION)
			ship.SetSoldierState(strategy.ShipsStateAssigned[ship])
			ship.SetDefensiveDistance(DefensiveRatio)
			pass
		ReasoningTimer = 0
		pass
	else:
		CommandeDefenders()
		pass
	ReasoningTimer += 1
	pass

func CommandeDefenders() -> void:
	for ship in Subordinades:
		var current_pos = ship.GetDefendingPosition()
		if ship.OnPosition and current_pos:
			var pos_to_defend = current_pos * BLOCKS_SIZE + OFFSET_POSITION
			var posibles_positions = [
				Vector2(0,5),
				Vector2(0,-5),
				Vector2(5,0),
				Vector2(-5,0)
			]
			var index = int(rand_range(0,posibles_positions.size()))
			var new_pos = current_pos + posibles_positions[index]
			while not GameMap.IsInRange(new_pos.x,new_pos.y):
				posibles_positions.pop_at(index)
				index = int(rand_range(0,posibles_positions.size()))
				new_pos = current_pos + posibles_positions[index]
				pass
			new_pos = GameMap.GetFreeCellCloserTo(new_pos)
			ship.SetTargetPosition(new_pos * BLOCKS_SIZE + OFFSET_POSITION)
			pass
		pass
	pass

func _on_VisualComander_body_entered(body):
	var bussy_cells = []
	if body.ID == IDS.UserID:
		bussy_cells = body.GetBussyCells()
		GameMap.SetBussyCells(bussy_cells)
		pass
	Core.Flank(soldierItem,VisionRange,GameMap)
	GameMap.FreeBussyCells(bussy_cells)
	pass # Replace with function body.

func _on_VisualComander_area_entered(area):
	var IsShip = area.ID == IDS.SoldierID or area.ID == IDS.CommandID
	if ShipsCollision and IsShip and area > self:
		var bussy_cells = area.GetBussyCells()
		GameMap.SetBussyCells(bussy_cells)
		SetTargetPosition(TargetPosition)
		GameMap.FreeBussyCells(bussy_cells)
		pass
	pass # Replace with function body.

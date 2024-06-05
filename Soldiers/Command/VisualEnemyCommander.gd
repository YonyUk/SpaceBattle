extends VisualEnemy

var Subordinades = []
var TotalEnemysSeen = []
var StrategyBrain = CommanderBrain.new()
var DefensiveRatio = 500
var ReasoningLatency = 10
var ReasoningTimer = 0
var DefensivePerimeter = 5

func _ready():
	soldierItem = $EnemyCommandItem
	Speed = Speed / 2 
	Subordinades = get_tree().current_scene.GetSubordinades(TEAM)
	Subordinades.append(self)
	selfFlagPosition = get_tree().current_scene.GetFlagPosition(TEAM)
	StrategyBrain.SetBlocksSize(BLOCKS_SIZE)
	StrategyBrain.SetDefensiveRatio(DefensiveRatio)
	StrategyBrain.SetOffsetPosition(OFFSET_POSITION)
	StrategyBrain.SetGameMap(GameMap)
	StrategyBrain.SetSectorsCount(SectorsCount)
	StrategyBrain.SetGameState(int(Subordinades.size() / 3),selfFlagPosition,Subordinades,TEAM)
	StrategyBrain.BuildMapSectors()
	var enemys = get_tree().current_scene.GetSubordinades(IDS.UserTeam)
	StrategyBrain.SetEnemys(IDS.UserTeam,enemys)
	var flag_enemy_position = get_tree().current_scene.GetFlagPosition(IDS.UserTeam)
	StrategyBrain.SetObjetivePoint(flag_enemy_position)
	SetLifePoints(Core.LifePoints * 10)
	pass

func SetDefensivePerimeter(perimeter: int) -> void:
	DefensivePerimeter = perimeter
	pass

func SetReasoningLatency(latency: int) -> void:
	ReasoningLatency = latency
	pass

func SetDefensiveRatio(ratio: int) -> void:
	DefensiveRatio = ratio
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
	Subordinades.append(self )
	StrategyBrain.SetAllys(Subordinades)
	var enemys = GetCurrentEnemys(IDS.UserTeam)
	if ReasoningTimer == ReasoningLatency:
		StrategyBrain.SetMinDefenders(int(Subordinades.size() / 3))
		StrategyBrain.SetMinSeekers(int(Subordinades.size() / 4))
		StrategyBrain.SetEnemys(IDS.UserTeam,enemys)
		var strategy = StrategyBrain.GetStrategy(IDS.UserTeam)
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
			var x = 0
			var y = 0
			if ship.global_position.x > pos_to_defend.x:
				x = current_pos.x - 5
				pass
			else:
				x = current_pos.x + 5
				pass
			
			if ship.global_position.y > pos_to_defend.y:
				y = current_pos.y - 5
				pass
			else:
				y = current_pos.y + 5
				pass
			var new_pos = GameMap.GetFreeCellCloserTo(Vector2(x,y))
			ship.SetTargetPosition(new_pos * BLOCKS_SIZE + OFFSET_POSITION)
			pass
		pass
	pass

func _on_VisualEnemyCommander_body_entered(body):
	var bussy_cells = []
	if body.ID == IDS.UserID:
		bussy_cells = body.GetBussyCells()
		GameMap.SetBussyCells(bussy_cells)
		pass
	Core.Flank(soldierItem,VisionRange,GameMap)
	GameMap.FreeBussyCells(bussy_cells)
	pass # Replace with function body.

func _on_VisualEnemyCommander_area_entered(area):
	var IsShip = area.ID == IDS.SoldierID or area.ID == IDS.CommandID
	if ShipsCollision and IsShip and area > self:
		var bussy_cells = area.GetBussyCells()
		GameMap.SetBussyCells(bussy_cells)
		SetTargetPosition(TargetPosition)
		GameMap.FreeBussyCells(bussy_cells)
		pass
	pass # Replace with function body.

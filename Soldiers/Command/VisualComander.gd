extends VisualSoldier

onready var LeftShooter = $LeftShooter
onready var RightShooter = $RightShooter
onready var CenterShooter = $CenterShooter

var Subordinades = []
var TotalEnemysSeen = []
var StrategyBrain = CommanderBrain.new()
var DefensiveRatio = 2000
var StaticReasoningLatency = 10
var ReasoningLatency = 10
var ReasoningTimer = 0
var DefensivePerimeter = 5
var AgentBrain = BDIStruct.new()
var MinDefenders = 1
var MinSeekers = 1
var StaticMinDefenders = 1
var StaticMinSeekers = 1
var StaticMaxDefenders = 1
var StaticMaxSeekers = 1
var SectorsSeen = []
var CurrentSectorToExplore = Vector2()
var exploredSectorDistance = 450
var FlagFound = false
var FlagInTargetPos = false
var EnemyFlagPos = Vector2()
var SectorsToExplore = []
var SectorSeen = false
var SoldiersShooted = []

func SetMaxDefenders(value:int) -> void:
	StaticMaxDefenders = value
	pass

func SetMaxSeekers(value:int) -> void:
	StaticMaxSeekers = value
	pass

func _ready():
	soldierItem = $CommandItem
	Speed = Speed / 2 
	CurrentSpeed = Speed
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
	for sector in StrategyBrain.MapSectors:
		if sector.x > GameMap.XSize() / 4:
			SectorsToExplore.append(Vector2(sector.x,sector.y))
			pass
		pass
	randomize()
	var i = int(rand_range(0,SectorsToExplore.size()))
	CurrentSectorToExplore = SectorsToExplore.pop_at(i)
	var enemys = get_tree().current_scene.GetSubordinades(IDS.EnemyTeam)
	StrategyBrain.SetEnemys(IDS.EnemyTeam,enemys)
	var flag_enemy_position = get_tree().current_scene.GetFlagPosition(IDS.EnemyTeam)
	SetLifePoints(Core.LifePoints * 10)
	LeftShooter.SetDamage(300)
	CenterShooter.SetDamage(300)
	RightShooter.SetDamage(300)
	pass

func _bullets_seen() -> Array:
	var result := []
	for ship in Subordinades:
		result.append_array(ship.bulletsSeen)
		pass
	return result

func _bullets_close_to_flag(bullets:Array) -> bool:
	for bullet in bullets:
		var pos := Vector2(int(bullet[1].x / BLOCKS_SIZE),int(bullet[1].y / BLOCKS_SIZE))
		var distance = (pos - selfFlagPosition).length_squared()
		if sqrt(distance) < DefensiveRatio:
			return true
		pass
	return false

func _soldier_shooted() -> Array:
	for ship in Subordinades:
		if ship.WasShooted() and not ship in SoldiersShooted:
			SoldiersShooted.append(ship)
			pass
		pass
	var i = 0
	while i < SoldiersShooted.size():
		if not SoldiersShooted[i].WasShooted():
			SoldiersShooted.pop_at(i)
			continue
		i += 1
		pass
	return SoldiersShooted

func _is_under_attack(enemys) -> bool:
	for enemy in enemys:
		var pos = Vector2(int(enemy.global_position.x / BLOCKS_SIZE),int(enemy.global_position.y / BLOCKS_SIZE))
		var distance = (pos - selfFlagPosition).length_squared()
		if sqrt(distance) < DefensiveRatio:
			return true
		pass
	return false

func _flag_in_target_pos(enemys) -> bool:
	if not FlagInTargetPos:
		for enemy in enemys:
			var pos = Vector2(int(enemy.global_position.x / BLOCKS_SIZE),int(enemy.global_position.y / BLOCKS_SIZE))
			var distance = (pos - CurrentSectorToExplore).length_squared()
			if sqrt(distance) < DefensiveRatio:
				FlagInTargetPos = true
				break
			pass
		pass
	else:
		for ship in Subordinades:
			var pos = Vector2(int(ship.global_position.x / BLOCKS_SIZE),int(ship.global_position.y / BLOCKS_SIZE))
			var distance = (pos - CurrentSectorToExplore).length_squared()
			if sqrt(distance) < DefensiveRatio * 10 and not ship.EnemyFlagFound:
				FlagInTargetPos = false
				break
			pass
		pass
	return FlagInTargetPos

func _search_flag():
	if SectorSeen and not FlagFound:
		var ready = false
		var i = 0
		while i < SectorsToExplore.size():
			if SectorsToExplore[i].x < GameMap.XSize() / 4:
				SectorsToExplore.pop_at(i)
				continue
			i += 1
			pass
		randomize()
		while SectorsToExplore.size() > 0:
			i = int(rand_range(0,SectorsToExplore.size()))
			var sector = SectorsToExplore.pop_at(i)
			if not sector in SectorsSeen:
				CurrentSectorToExplore = sector
				ready = true
				SectorSeen = false
				break
			pass
		if not ready:
			while SectorsSeen.size() > 0:
				SectorsToExplore.append(SectorsSeen.pop_front())
				pass
			pass
		pass
	pass

func search_flag() -> void:
	_search_flag()
	ReasoningLatency = StaticReasoningLatency
	if Subordinades.size() - MinDefenders - MinSeekers > 0:
		if MinSeekers < StaticMaxSeekers:
			MinSeekers += 1
			pass
		pass
	elif MinDefenders > StaticMinDefenders:
		MinDefenders -= 1
		pass
	pass

func get_flag() -> void:
	ReasoningLatency = StaticReasoningLatency
	if MinDefenders > StaticMinDefenders:
		MinDefenders -= 1
		if MinSeekers < StaticMaxSeekers:
			MinSeekers += 1
			pass
		pass
	pass

func attack() ->void:
	get_flag()
	ReasoningLatency = int(StaticReasoningLatency / 2)
	pass

func defend() -> void:
	ReasoningLatency = int(StaticReasoningLatency / 2)
	if MinSeekers > StaticMinSeekers:
		MinSeekers -= 1
		if MinDefenders < StaticMaxDefenders:
			MinDefenders += 1
			pass
		pass
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
	StaticReasoningLatency = latency
	ReasoningTimer = latency
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

func EXECUTE(action:String) -> void:
	if action == 'search_flag':
		search_flag()
		pass
	if action == 'get_flag':
		get_flag()
		pass
	if action == 'defend':
		defend()
		pass
	pass

func _update_perception(enemys):
	for ship in Subordinades:
		var distance = (ship.global_position - CurrentSectorToExplore*BLOCKS_SIZE + OFFSET_POSITION).length_squared()
		if sqrt(distance) < exploredSectorDistance and not CurrentSectorToExplore in SectorsSeen:
			SectorsSeen.append(CurrentSectorToExplore)
			SectorSeen = true
			pass
		for sector in SectorsToExplore:
			distance = (ship.global_position - sector*BLOCKS_SIZE + OFFSET_POSITION).length_squared()
			if sqrt(distance) < exploredSectorDistance and not sector in SectorsSeen:
				SectorsSeen.append(sector)
				if sector == CurrentSectorToExplore:
					SectorSeen = true
					pass
				pass
			pass
		if ship.EnemyFlagFound:
			FlagFound = true
			EnemyFlagPos = ship.EnemyFlagPosition
			CurrentSectorToExplore = EnemyFlagPos
			pass
		pass
	var percep = CommanderPerception.new()
	percep.setFlagFound(FlagFound)
	percep.setUnderAttack(_is_under_attack(enemys))
	percep.setFlagInTargetPos(_flag_in_target_pos(enemys))
	percep.setEnemys(enemys)
	percep.setSoldiersShooted(_soldier_shooted())
	var bullets = _bullets_seen()
	percep.setBullets(bullets)
	percep.setBulletCloseToFlag(_bullets_close_to_flag(bullets))
	EXECUTE(AgentBrain.ACTION(percep))
	if Subordinades.size() <= StaticMaxDefenders and StaticMaxDefenders > 0:
		StaticMaxDefenders -= 1
		pass
	if Subordinades.size() <= StaticMaxSeekers and StaticMaxSeekers > 1:
		StaticMaxSeekers -= 1
		pass
	pass

func _physics_process(delta):
	._physics_process(delta)
	var enemys = GetCurrentEnemys(IDS.EnemyTeam)
	_update_perception(enemys)
	StrategyBrain.SetMinDefenders(MinDefenders)
	StrategyBrain.SetMinSeekers(MinSeekers)
	Subordinades = get_tree().current_scene.GetSubordinades(TEAM)
	Subordinades.append(self)
	StrategyBrain.SetAllys(Subordinades)
	StrategyBrain.SetObjetivePoint(CurrentSectorToExplore)
	
	if ReasoningTimer >= ReasoningLatency:
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
			randomize()
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

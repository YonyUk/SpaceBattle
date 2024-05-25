extends VisualSoldier

onready var LeftShooter = $LeftShooter
onready var RightShooter = $RightShooter
onready var CenterShooter = $CenterShooter

var Subordinades = []
var TotalEnemysSeen = []
var StrategyBrain = CommanderBrain.new()
var DefensiveRatio = 500

func _ready():
	soldierItem = $CommandItem
	Subordinades = get_tree().current_scene.GetSubordinades(TEAM)
	selfFlagPosition = get_tree().current_scene.GetFlagPosition(TEAM)
	StrategyBrain.SetDefensiveRatio(DefensiveRatio)
	StrategyBrain.SetBlocksSize(BLOCKS_SIZE)
	StrategyBrain.SetGameMap(GameMap)
	StrategyBrain.SetSectorsCount(SectorsCount)
	StrategyBrain.BuildMapSectors()
	StrategyBrain.SetGameState(5,selfFlagPosition,Subordinades,TEAM)
	var enemys = get_tree().current_scene.GetSubordinades(IDS.EnemyTeam)
	var enemy_flag_position = get_tree().current_scene.GetFlagPosition(IDS.EnemyTeam)
	StrategyBrain.SetEnemys(IDS.EnemyTeam,enemys)
	StrategyBrain.SetEnemyFlagPosition(IDS.EnemyTeam,enemy_flag_position)
#	StrategyBrain.GetStrategy(IDS.EnemyTeam)
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

func SetDefensiveRatio(ratio: int) -> void:
	DefensiveRatio = ratio
	pass

func SetMapLimits(size:Vector2) -> void:
	LeftShooter.SetMapLimits(size)
	RightShooter.SetMapLimits(size)
	CenterShooter.SetMapLimits(size)
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

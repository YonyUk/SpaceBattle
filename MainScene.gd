extends Node2D

onready var blockInstancer = preload("res://Blocks/SteelBlock.tscn")
onready var asteroidInstancer = preload("res://Blocks/asteroid1.tscn")
onready var asteroid2Instancer = preload("res://Blocks/Asteroid2.tscn")
onready var asteroid3Instancer = preload("res://Blocks/Asteroid3.tscn")
onready var steelInstancer = preload("res://Blocks/SteelPiece.tscn")
onready var steel2Instancer = preload("res://Blocks/SteelPiece2.tscn")
onready var playerInstancer = preload("res://Player/Player.tscn")
onready var backgroundInstancer = preload("res://background/BackGround.tscn")
onready var enemyInstancer = preload("res://Soldiers/VisualEnemy.tscn")
onready var soldiersInstancer = preload("res://Soldiers/VisualSoldier.tscn")
onready var userCommanderInstancer = preload("res://Soldiers/Command/VisualComander.tscn")
onready var enemyCommanderInstancer = preload("res://Soldiers/Command/VisualEnemyCommander.tscn")
onready var FlagInstancer = preload("res://Flags/Flag.tscn")
onready var BackGround = $BackGround

var SIMULATION_STARTED = false
var game_engine = GameEngine.new()
var WIDTH = 0
var HEIGHT = 0
var ROW_SECTORS = 10
var COLUMN_SECTORS = 10
var SECTORS_DIMENTIONS = 10
var BLOCK_SIZE = 46
var OFFSET_POSITION = Vector2(BLOCK_SIZE / 2,BLOCK_SIZE / 2)
var MAX_SOLDIERS = 8
var VisionRange = 300
var PerceptionLatency = 10
var CommanderLatency = 800
var UserDefensiveRatio = 35
var SoldiersLifePoints = 1000
var SoldierSaveDistance = 200
var MaxDefenders = 5
var MaxSeekers = 5
var EnemyMaxDefenders = 5
var EnemyMaxSeekers = 5
var SoldiersLowLimitsLifePoints = int(SoldiersLifePoints / 3)
var FriendlyFire = false
var Player = null
var UserSoldiers = []
var EnemySoldiers = []
var UserCommander = null
var EnemyCommander = null
var IDS = AreasIDS.new()
var FlagsTeams = {}

func CurrentMap() -> Map:
	return game_engine.GameMap

func GetFriendlyFire() -> bool:
	return FriendlyFire

func AddExplosion(explosion) -> void:
	add_child(explosion)
	pass

func DeleteShip(ship,team: String) -> void:
	var index = 0
	if team == IDS.UserTeam:
		index = UserSoldiers.find(ship)
		UserSoldiers.pop_at(index)
		pass
	else:
		index = EnemySoldiers.find(ship)
		EnemySoldiers.pop_at(index)
		pass
	remove_child(ship)
	pass

func GetSubordinades(team:String) -> Array:
	var result = []
	if team == IDS.UserTeam:
		result += UserSoldiers
		pass
	else:
		result += EnemySoldiers
		pass
	return result

func AddBullet(bullet) -> void:
	add_child(bullet)
	pass

func GenerateSoldiers():
	EnemySoldiers += game_engine.GenerateSoldiers(IDS.EnemyTeam)
	UserSoldiers += game_engine.GenerateSoldiers(IDS.UserTeam)
	for soldier in EnemySoldiers:
		add_child(soldier)
		soldier.SetMapLimits(GetMapLimits())
		soldier.SetPerceptionLatency(PerceptionLatency)
		soldier.AutoSetVisionRange()
		soldier.SetVisionRange(VisionRange)
		pass
	for soldier in UserSoldiers:
		add_child(soldier)
		soldier.SetMapLimits(GetMapLimits())
		soldier.SetPerceptionLatency(PerceptionLatency)
		soldier.AutoSetVisionRange()
		soldier.SetVisionRange(VisionRange)
		pass
	GenerateCommanders()
	pass

func GenerateCommanders() -> void:
	UserCommander = game_engine.GenerateCommander(IDS.UserTeam,UserDefensiveRatio,MaxDefenders,MaxSeekers)
	add_child(UserCommander)
	UserCommander.SetMapLimits(GetMapLimits())
	UserCommander.SetPerceptionLatency(PerceptionLatency)
	UserCommander.AutoSetVisionRange()
	UserCommander.SetVisionRange(VisionRange)
	UserCommander.SetReasoningLatency(CommanderLatency)
	
	EnemyCommander = game_engine.GenerateCommander(IDS.EnemyTeam,UserDefensiveRatio,EnemyMaxDefenders,EnemyMaxSeekers)
	add_child(EnemyCommander)
	EnemyCommander.SetMapLimits(GetMapLimits())
	EnemyCommander.SetPerceptionLatency(PerceptionLatency)
	EnemyCommander.AutoSetVisionRange()
	EnemyCommander.SetVisionRange(VisionRange)
	EnemyCommander.SetReasoningLatency(CommanderLatency)
	pass

func GetMapLimits():
	return game_engine.GetMapLimits()

func SetPlayer() -> void:
	Player = playerInstancer.instance()
	add_child(Player)
	Player.SetGameParameters(BLOCK_SIZE,OFFSET_POSITION,CurrentMap())
	Player.SetViewLimits(GetMapLimits())
	Player.global_position = game_engine.GetPlayerPosition()
	pass

func SetFlags() -> void:
	var user_flag = game_engine.SetFlag(IDS.UserTeam)
	var enemy_flag = game_engine.SetFlag(IDS.EnemyTeam)
	add_child(user_flag)
	add_child(enemy_flag)
	FlagsTeams[IDS.UserTeam] = Vector2(int(user_flag.global_position.x / BLOCK_SIZE),int(user_flag.global_position.y / BLOCK_SIZE))
	FlagsTeams[IDS.EnemyTeam] = Vector2(int(enemy_flag.global_position.x / BLOCK_SIZE),int(enemy_flag.global_position.y / BLOCK_SIZE))	
	pass

func GetFlagPosition(team: String):
	return FlagsTeams[team]

func ExportMaps(maps: int) -> void:
	for i in range(maps):
		print('map',i)
		var name = 'MAP' + str(i)
		game_engine.CreateMap(ROW_SECTORS,COLUMN_SECTORS,SECTORS_DIMENTIONS)
		game_engine.ExportMap('/media/yonyuk/Nuevo vol1/Projects/Python/MachineLearning/MapsSet',name)
		pass
	pass

func _ready():
#	var size = game_engine.LoadMap('SavedMaps/map10.json')
#	COLUMN_SECTORS = size[0]
#	ROW_SECTORS = size[1]
	# setting up the game_engine
	
	var screen = get_viewport_rect()
	var bg_position = Vector2(screen.size.x / 2,screen.size.y / 2)
	BackGround.global_position = bg_position
	ConfigSimulation()
	pass

func _physics_process(delta):
	if Player and SIMULATION_STARTED:
		BackGround.position = Player.position
		pass
	pass

func DrawMap():
	game_engine.CreateMap(ROW_SECTORS,COLUMN_SECTORS,SECTORS_DIMENTIONS)
	WIDTH = game_engine.GameMap.map[0].size() * BLOCK_SIZE
	HEIGHT = game_engine.GameMap.map.size() * BLOCK_SIZE
	for i in range(game_engine.GameMap.map[0].size()):
		for j in range(game_engine.GameMap.map.size()):
			var pos = Vector2(i,j) * BLOCK_SIZE + OFFSET_POSITION
			if not game_engine.GameMap.map[j][i]:
				var block = asteroid2Instancer.instance()
				block.position = pos
				block.scale = Vector2.ONE * (float(BLOCK_SIZE) / 30)
				add_child(block)
				pass
			pass
		pass
	pass

func Set_Simulation_Parameters() -> void:
	ROW_SECTORS = $WindowDialog/ROW_SECTORS.value
	COLUMN_SECTORS = $WindowDialog/COLUMN_SECTORS.value
	SECTORS_DIMENTIONS = $WindowDialog/SECTORS_COUNT.value
	MAX_SOLDIERS = $WindowDialog/SOLDIERS.value
	VisionRange = $WindowDialog/VISION_RANGE.value
	PerceptionLatency = $WindowDialog/SOLDIER_LATENCY.value
	CommanderLatency = $WindowDialog/COMMANDER_LATENCY.value
	UserDefensiveRatio = $WindowDialog/SAVE_DISTANCE.value
	SoldiersLifePoints = $WindowDialog/LIFE_POINTS.value
	SoldierSaveDistance = $WindowDialog/SAVE_DISTANCE_SOLDIERS.value
	MaxDefenders = $WindowDialog/MAX_DEFENDERS.value
	MaxSeekers = $WindowDialog/MAX_SEEKERS.value
	EnemyMaxDefenders = $WindowDialog/ENEMY_MAX_DEFENDERS.value
	EnemyMaxSeekers = $WindowDialog/ENEMY_MAX_SEEKERS.value
	pass

func StartSimulation() -> void:
	SIMULATION_STARTED = true
	game_engine.SetSoldierSaveDistance(SoldierSaveDistance)
	game_engine.SetMapParameters(BLOCK_SIZE,OFFSET_POSITION)
	game_engine.SetSoldiersLifePoints(SoldiersLifePoints)
	game_engine.SetSoldiersLowLimitLifePoints(SoldiersLowLimitsLifePoints)
	game_engine.SetEnemyInstancer(enemyInstancer)
	game_engine.SetSoldierInstancer(soldiersInstancer)
	game_engine.SetMaxSoldiers(MAX_SOLDIERS)
	game_engine.SetColumnSectors(COLUMN_SECTORS)
	game_engine.SetRowSectors(ROW_SECTORS)
	game_engine.SetSectorsDimentions(SECTORS_DIMENTIONS)
	game_engine.SetPerceptionLatency(PerceptionLatency)
	game_engine.SetVisionRange(VisionRange)
	game_engine.SetUserCommanderInstancer(userCommanderInstancer)
	game_engine.SetEnemyCommanderInstancer(enemyCommanderInstancer)
	game_engine.SetFlagInstancer(FlagInstancer)
	DrawMap()
	SetFlags()
	GenerateSoldiers()
	SetPlayer()
	pass

func ConfigSimulation() -> void:
	$WindowDialog.show()
	$WindowDialog.popup_centered()
	pass

func ClearScene() -> void:
	var nodes_to_keep = [BackGround,$MainCamera,$WindowDialog]
	for child in get_children():
		if not child in nodes_to_keep:
			child.queue_free()
			pass
		pass
	pass

func _on_WindowDialog_start():
	SIMULATION_STARTED = true
	Set_Simulation_Parameters()
	StartSimulation()
	pass # Replace with function body.

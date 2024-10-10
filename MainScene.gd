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
onready var EndSimulationLabel = $EndSimulationLabel

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
var UserFlag = null
var EnemyFlag = null
var IDS = AreasIDS.new()
var FlagsTeams = {}
var CameraScale = Vector2()
var SimulationsResults = {}
var SimulationID = 0
var Loop = false
var Count = 0

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
	var MapSize = game_engine.GetMapLimits($WindowDialog.MapLoad)
	var screen_size = get_viewport().size
	CameraScale = Vector2(float(MapSize.x / screen_size.x),float(MapSize.y / screen_size.y)) * 2
	CameraScale = Vector2(8,20)
	return MapSize

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
	
	UserFlag = user_flag
	EnemyFlag = enemy_flag
	
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
	ConfigSimulation()
	pass

func _physics_process(delta):
	Count = $WindowDialog/OnLoop/on_loop_value.value
	if Player and SIMULATION_STARTED:
		EndSimulationLabel.rect_global_position = Player.global_position
		if UserCommander and UserFlag:
			UserCommander.SetFlagUnderAttack(UserFlag.UnderAttack)
			pass
		if EnemyCommander and EnemyFlag:
			EnemyCommander.SetFlagUnderAttack(EnemyFlag.UnderAttack)
			pass
		pass
	pass

func DrawMap():
	if not $WindowDialog.MapLoad:
		game_engine.CreateMap(ROW_SECTORS,COLUMN_SECTORS,SECTORS_DIMENTIONS)
		pass
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
	if $WindowDialog.MapLoad:
		var size = game_engine.LoadMap($WindowDialog.map)
		COLUMN_SECTORS = size[0]
		ROW_SECTORS = size[1]
		pass
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
	Player.SetCameraScale(CameraScale)
	pass

func ConfigSimulation() -> void:
	$WindowDialog.MapLoad = false
	$WindowDialog.show()
	$WindowDialog.popup_centered()
	pass

func ClearScene() -> void:
	var nodes_to_keep = [$MainCamera,$WindowDialog,EndSimulationLabel,$SaveResultsSimulations]
	EnemySoldiers.clear()
	UserSoldiers.clear()
	for child in get_children():
		if not child in nodes_to_keep:
			child.queue_free()
			pass
		pass
	ConfigSimulation()
	EndSimulationLabel.text = ''
	pass

func EndSimulation(team):
	EndSimulationLabel.text = 'End of Simulation\n'
	SimulationsResults['Simulation' + str(SimulationID)] = {
		'SIZE': [ROW_SECTORS * SECTORS_DIMENTIONS,COLUMN_SECTORS*SECTORS_DIMENTIONS],
		'SOLDIERS':MAX_SOLDIERS,
		'VISION_RANGE':VisionRange,
		'SOLDIER_REASONING_LATENCY':PerceptionLatency,
		'COMMANDER_REASONING_LATENCY':CommanderLatency,
		'FLAG_DEFENSIVE_RATIO':UserDefensiveRatio,
		'LIFE_POINTS':SoldiersLifePoints,
		'SAVE_DISTANCE_BETTEWN_SOLDIERS':SoldierSaveDistance,
		'USER_MAX_DEFENDERS':MaxDefenders,
		'USER_MAX_SEEKERS':MaxSeekers,
		'ENEMY_MAX_DEFENDERS':EnemyMaxDefenders,
		'ENEMY_MAX_SEEKERS':EnemyMaxSeekers,
		'WINNER_TEAM':team
	}
	SimulationID += 1
	if Loop and Count > 0:
		Count -= 1
		var nodes_to_keep = [$MainCamera,$WindowDialog,EndSimulationLabel,$SaveResultsSimulations]
		EnemySoldiers.clear()
		UserSoldiers.clear()
		for child in get_children():
			if not child in nodes_to_keep:
				child.queue_free()
				pass
			pass
		EndSimulationLabel.text = ''
		StartSimulation()
		pass
	pass

func _on_WindowDialog_start():
	SIMULATION_STARTED = true
	Set_Simulation_Parameters()
	StartSimulation()
	pass # Replace with function body.

func _on_SaveResultsSimulations_file_selected(path):
	var file = File.new()
	if file.open(path,File.WRITE) == OK:
		var content = JSON.print(SimulationsResults)
		file.store_string(content)
		file.close()
		pass
	$SaveResultsSimulations.hide()
	pass # Replace with function body.

func _on_WindowDialog_save_results():
	$SaveResultsSimulations.show()
	$SaveResultsSimulations.popup_centered()
	pass # Replace with function body.

func _on_WindowDialog_loop(state):
	Loop = state
	pass # Replace with function body.

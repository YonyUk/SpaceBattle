extends Node2D

onready var blockInstancer = preload("res://Blocks/SteelBlock.tscn")
onready var playerInstancer = preload("res://Player/Player.tscn")
onready var backgroundInstancer = preload("res://background/BackGround.tscn")
onready var enemyInstancer = preload("res://Soldiers/VisualEnemy.tscn")
onready var soldiersInstancer = preload("res://Soldiers/VisualSoldier.tscn")
onready var userCommanderInstancer = preload("res://Soldiers/Command/VisualComander.tscn")
onready var FlagInstancer = preload("res://Flags/Flag.tscn")

var game_engine = GameEngine.new()
var WIDTH = 0
var HEIGHT = 0
var ROW_SECTORS = 10
var COLUMN_SECTORS = 10
var SECTORS_DIMENTIONS = 10
var BLOCK_SIZE = 30
var OFFSET_POSITION = Vector2(15,15)
var MAX_SOLDIERS = 8
var VisionRange = 300
var PerceptionLatency = 25
var Player = null
var BackGround = null
var UserSoldiers = []
var EnemySoldiers = []
var UserCommander = null
var EnemyCommander = null
var IDS = AreasIDS.new()
var FlagsTeams = {}
var UserDefensiveRatio = 500

func CurrentMap() -> Map:
	return game_engine.GameMap

func GetSubordinades(team:String) -> Array:
	if team == IDS.UserTeam:
		return UserSoldiers
	return EnemySoldiers

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
	UserCommander = game_engine.GenerateCommander(IDS.UserTeam,UserDefensiveRatio)
	add_child(UserCommander)
	UserCommander.SetMapLimits(GetMapLimits())
	UserCommander.SetPerceptionLatency(PerceptionLatency)
	UserCommander.AutoSetVisionRange()
	UserCommander.SetVisionRange(VisionRange)
	pass

func GetMapLimits():
	return game_engine.GetMapLimits()

func SetPlayer() -> void:
	Player = playerInstancer.instance()
	add_child(Player)
	Player.SetGameParameters(BLOCK_SIZE,OFFSET_POSITION,CurrentMap())
	Player.SetViewLimits(GetMapLimits())
	var pos = game_engine.GetFreeMapPosition()
	Player.global_position = pos * BLOCK_SIZE + OFFSET_POSITION
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

func _ready():
	# setting up the game_engine
	game_engine.SetMapParameters(BLOCK_SIZE,OFFSET_POSITION)
	game_engine.SetEnemyInstancer(enemyInstancer)
	game_engine.SetSoldierInstancer(soldiersInstancer)
	game_engine.SetMaxSoldiers(MAX_SOLDIERS)
	game_engine.SetColumnSectors(COLUMN_SECTORS)
	game_engine.SetRowSectors(ROW_SECTORS)
	game_engine.SetSectorsDimentions(SECTORS_DIMENTIONS)
	game_engine.SetPerceptionLatency(PerceptionLatency)
	game_engine.SetVisionRange(VisionRange)
	game_engine.SetUserCommanderInstancer(userCommanderInstancer)
	game_engine.SetFlagInstancer(FlagInstancer)
	BackGround = backgroundInstancer.instance()
	add_child(BackGround)
	DrawMap()
	SetFlags()
	GenerateSoldiers()
	SetPlayer()
	pass

func _physics_process(delta):
	BackGround.position = Player.position
	for soldier in EnemySoldiers:
		if soldier.OnPosition:
			var new_pos = game_engine.GetFreeMapPosition()
			soldier.SetTargetPosition(new_pos * BLOCK_SIZE + OFFSET_POSITION)
			pass
		pass
	for soldier in UserSoldiers:
		if soldier.OnPosition:
			var new_pos = game_engine.GetFreeMapPosition()
			soldier.SetTargetPosition(new_pos * BLOCK_SIZE + OFFSET_POSITION)
			pass
		pass
	if UserCommander.OnPosition:
		var new_pos = game_engine.GetFreeMapPosition()
		UserCommander.SetTargetPosition(new_pos * BLOCK_SIZE + OFFSET_POSITION)
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
				var block = blockInstancer.instance()
				block.position = pos
				add_child(block)
				pass
			pass
		pass
	pass
extends Node2D

onready var blockInstancer = preload("res://Blocks/SteelBlock.tscn")
onready var playerInstancer = preload("res://Player/Player.tscn")
onready var backgroundInstancer = preload("res://background/BackGround.tscn")
onready var enemyInstancer = preload("res://Soldiers/VisualEnemy.tscn")
onready var soldiersInstancer = preload("res://Soldiers/VisualSoldier.tscn")

var game_engine = GameEngine.new()
var WIDTH = 0
var HEIGHT = 0
var ROW_SECTORS = 10
var COLUMN_SECTORS = 10
var SECTORS_DIMENTIONS = 10
var BLOCK_SIZE = 30
var OFFSET_POSITION = Vector2(15,15)
var MAX_SOLDIERS = 5
var Player = null
var BackGround = null
var soldiers = []

func CurrentMap():
	return game_engine.GameMap

func GenerateSoldiers():
	soldiers += game_engine.GenerateSoldiers(MAX_SOLDIERS,BLOCK_SIZE,OFFSET_POSITION,enemyInstancer,CurrentMap())
	soldiers += game_engine.GenerateSoldiers(MAX_SOLDIERS,BLOCK_SIZE,OFFSET_POSITION,soldiersInstancer,CurrentMap())
	for soldier in soldiers:
		add_child(soldier)
		soldier.AutoSetVisionRange()
		pass
	pass

func GetMapLimits():
	var x = COLUMN_SECTORS * SECTORS_DIMENTIONS
	var y = ROW_SECTORS * SECTORS_DIMENTIONS
	return Vector2(x,y) * BLOCK_SIZE

func _ready():
	game_engine.SetMapParameters(BLOCK_SIZE,OFFSET_POSITION)
	BackGround = backgroundInstancer.instance()
	add_child(BackGround)
	DrawMap()
	GenerateSoldiers()
	Player = playerInstancer.instance()
	add_child(Player)
	Player.SetGameParameters(BLOCK_SIZE,OFFSET_POSITION,CurrentMap())
	Player.SetViewLimits(GetMapLimits())
	var pos = game_engine.GetFreeMapPosition()
	Player.global_position = pos * BLOCK_SIZE + OFFSET_POSITION
	pass

func _physics_process(delta):
	BackGround.position = Player.position
	for soldier in soldiers:
		if soldier.OnPosition:
			var new_pos = game_engine.GetFreeMapPosition()
			soldier.SetTargetPosition(new_pos * BLOCK_SIZE + OFFSET_POSITION)
			pass
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

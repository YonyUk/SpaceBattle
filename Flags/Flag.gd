extends Area2D

class_name Flag

onready var redFlagItemInstancer = preload("res://Flags/red_flag.tscn")
onready var blueFlagItemInstancer = preload("res://Flags/blue_flag.tscn")

var IDS = AreasIDS.new()
var ID = IDS.FlagID
var TEAM = ''
var COLOR = ''
var LIFE = 10000
var UnderAttack = false
var counter = 180
var _counter = 0

var flagsItem = {}

func _ready():
	flagsItem = {
	IDS.RedFlag: redFlagItemInstancer.instance(),
	IDS.BlueFlag: blueFlagItemInstancer.instance()
	}
	add_child(flagsItem[COLOR])
	pass

func _physics_process(delta):
	if _counter < counter:
		_counter += 1
		pass
	else:
		UnderAttack = false
		pass
	pass

func SetFlagItem(color: String) -> void:
	COLOR = color
	pass

func Destroy(damage:int) -> void:
	_counter = 0
	UnderAttack = true
	LIFE -= damage
	if LIFE <= 0:
		get_tree().current_scene.EndSimulation(TEAM)
		pass
	pass

func SetTeam(team: String) -> void:
	TEAM = team
	pass

extends Area2D

class_name Flag

onready var redFlagItemInstancer = preload("res://Flags/red_flag.tscn")
onready var blueFlagItemInstancer = preload("res://Flags/blue_flag.tscn")

var IDS = AreasIDS.new()
var ID = IDS.FlagID
var TEAM = ''
var COLOR = ''

var flagsItem = {}

func _ready():
	flagsItem = {
	IDS.RedFlag: redFlagItemInstancer.instance(),
	IDS.BlueFlag: blueFlagItemInstancer.instance()
	}
	add_child(flagsItem[COLOR])
	pass

func SetFlagItem(color: String) -> void:
	COLOR = color
	pass

func SetTeam(team: String) -> void:
	TEAM = team
	pass

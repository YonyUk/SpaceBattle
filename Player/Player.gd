extends KinematicBody2D

onready var collisionDetector = $Collisioner

onready var playerItem = $PlayerItem
onready var Shooter = $PlayerItem/Shooter
var Speed = 200
var MoveDirection := Vector2()
var LIMIT_X = 0
var LIMIT_Y = 0
var MoveUp = false
var MoveDown = false
var MoveLeft = false
var MoveRight = false
var ID = 'PLAYER'
var TEAM = "USER"

func _ready():
	pass # Replace with function body.

func SetViewLimits(size: Vector2):
	LIMIT_X = size.x
	LIMIT_Y = size.y
	Shooter.SetMapLimits(size)
	pass

func SetGameParameters(blocks_size: int, offset_positions: Vector2,map:Map):
	$PlayerItem.SetGameParameters(blocks_size,offset_positions)
	$PlayerItem.SetGameMap(map)
	pass

func GetBussyCells() -> Array:
	return $PlayerItem.GetBussyCells()

func _physics_process(delta):
	MoveDirection = Vector2()

	if (Input.is_action_pressed("ui_down") or MoveDown) and global_position.y < LIMIT_Y:
		MoveDirection.y += 1
		pass

	if (Input.is_action_pressed("ui_up") or MoveUp) and global_position.y > 0:
		MoveDirection.y -= 1
		pass

	if (Input.is_action_pressed("ui_left") or MoveLeft) and global_position.x > 0:
		MoveDirection.x -= 1
		pass

	if (Input.is_action_pressed("ui_right") or MoveRight) and global_position.x < LIMIT_X:
		MoveDirection.x += 1
		pass
	
	if Input.is_action_pressed("rotate_left"):
		$PlayerItem.rotation_degrees -= 5
		pass
	
	if Input.is_action_pressed("rotate_right"):
		$PlayerItem.rotation_degrees += 5
		pass
	
	if Input.is_action_just_pressed("shoot"):
		var bullet = Shooter.Shoot(TEAM)
		bullet.rotation = playerItem.rotation
		get_tree().current_scene.AddBullet(bullet)
		pass

	move_and_slide(MoveDirection * Speed)
	clamp(global_position.x,15,LIMIT_X - 15)
	clamp(global_position.y,15,LIMIT_Y - 15)
	pass

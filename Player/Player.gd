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
var LastPosition = Vector2()
var LastRotation = 0
var OperatingSystem = null
var InstructionsOn = false

func _ready():
	LastPosition = global_position
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

func Rotate() -> void:
	var vector = global_position - LastPosition
	if vector.length_squared() > 0:
		$PlayerItem.rotation = vector.angle() + PI / 2
		pass
	pass

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
	
	move_and_slide(MoveDirection * Speed)
	clamp(global_position.x,15,LIMIT_X - 15)
	clamp(global_position.y,15,LIMIT_Y - 15)
	
	var rotating = false
	
	if Input.is_action_pressed("rotate_left") and not InstructionsOn:
		$PlayerItem.rotation_degrees -= 3
		rotating = true
		pass
	
	if Input.is_action_pressed("rotate_right") and not InstructionsOn:
		$PlayerItem.rotation_degrees += 5
		rotating = true
		pass
	
	if Input.is_action_just_pressed("shoot") and not InstructionsOn:
		var bullet = Shooter.Shoot(TEAM)
		bullet.rotation = playerItem.rotation
		get_tree().current_scene.AddBullet(bullet)
		pass

	if Input.is_action_just_pressed("Instructions_Input"):
		if InstructionsOn:
			$Instructions.modulate.a = 0
			$Button.modulate.a = 0
			InstructionsOn = false
			pass
		else:
			$Instructions.modulate.a = 0.7
			$Button.modulate.a = 0.7
			InstructionsOn = true
			pass
		pass

# idea para implementar despues
	if not rotating:
		#Rotate()
		pass
	LastPosition = global_position
	#LastRotation = rotation
	pass

async func send_command():
	pass

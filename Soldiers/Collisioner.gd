extends Node2D

class_name SoldierCollisionDetector

onready var Front = $Front/FrontDirector
onready var Left = $Left/LeftDirector
onready var FrontLeft = $FrontLeft/FrontLeftDirector
onready var Right = $Right/RightDirector
onready var FrontRight = $FrontRight/FrontRightDirector
onready var Back = $Back/BackDirector
onready var BackLeft = $BackLeft/BackLeftDirector
onready var BackRight = $BackRight/BackRightDirector

func _ready():
	pass

func LeftColliding() -> bool:
	return $Left.is_colliding() or $Left2.is_colliding() or $Left3.is_colliding()

func RightColliding() -> bool:
	return $Right.is_colliding() or $Right2.is_colliding() or $Right3.is_colliding()

func FrontColliding() -> bool:
	return $Front.is_colliding() or $Front2.is_colliding() or $Front3.is_colliding()

func FrontLeftColliding() -> bool:
	return $FrontLeft.is_colliding()

func FrontRightColliding() -> bool:
	return $FrontRight.is_colliding()

func BackLeftColliding() -> bool:
	return $BackLeft.is_colliding()

func BackRightColliding() -> bool:
	return $BackRight.is_colliding()

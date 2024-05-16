extends Area2D

class_name SoldierItem

onready var collisionDetector = $Collisioner

var IDS = AreasIDS.new()
var ID = IDS.CollisionerID
var TEAM = IDS.UserTeam

func GetFlankPosition():
	if not collisionDetector.FrontColliding():
		return collisionDetector.Front.global_position
	if not collisionDetector.FrontLeftColliding():
		return collisionDetector.FrontLeft.global_position
	if not collisionDetector.FrontRightColliding():
		return collisionDetector.FrontRight.global_position
	if not collisionDetector.LeftColliding():
		return collisionDetector.Left.global_position
	if not collisionDetector.RightColliding():
		return collisionDetector.Right.global_position
	if not collisionDetector.BackLeftColliding():
		return collisionDetector.BackLeft.global_position
	if not collisionDetector.BackRightColliding():
		return collisionDetector.BackRight.global_position
	return collisionDetector.Back.global_position

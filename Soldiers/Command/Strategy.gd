extends Node

class_name Strategy

var ShipsStateAttacking = 0
var ShipStateDefend = 1
var ShipStateAutoDefend = 2

var ShipsPositionsAssigned = {
	
}

var ShipsStateAssigned = {
	
}

func AssignPositionToShip(ship,pos: Vector2) -> void:
	ShipsPositionsAssigned[ship] = pos
	pass

func AssignShipState(ship,state: int) -> void:
	ShipsStateAssigned[ship] = state
	pass

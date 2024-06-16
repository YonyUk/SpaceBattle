extends Node

class_name GameState

var Teams = {}
var FlagsLocations = {}
var States = ShipStates.new()
var ShipsStateAttacking = States.ShipsStateAttacking
var ShipStateDefend = States.ShipStateDefend
var ShipStateAutoDefend = States.ShipStateAutoDefend

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

func EqualTo(other: GameState) -> bool:
	return other.ShipsPositionsAssigned == ShipsPositionsAssigned and other.ShipsStateAssigned == ShipsStateAssigned

# sets the flag position for a team
func SetFlagLocation(team: String, pos: Vector2) -> void:
	if not team in FlagsLocations.keys():
		FlagsLocations[team] = pos
		pass
	pass

# sets the team and its ships
func SetTeam(team: String, ships: Array) -> void:
	if not team in Teams.keys():
		Teams[team] = ships
		pass
	pass

# the average distance from a team to its flag
func DistanceAverageToSelfFlag(team: String) -> float:
	var distance = 0
	for soldier in Teams[team]:
		if soldier in ShipsStateAssigned.keys() and ShipsStateAssigned[soldier] == States.ShipStateSeeking:
			continue
		var vector: Vector2 = soldier.global_position - FlagsLocations[team]
		distance += vector.length_squared()
		pass
	return distance / Teams[team].size()

# the average distance from a team to the flag of another team
func DistanceAverageFromTeamToFlag(self_team: Array,other_team: String) -> float:
	var distance = 0
	for soldier in self_team:
		var vector: Vector2 = soldier.global_position - FlagsLocations[other_team]
		distance += vector.length_squared()
		pass
	return distance / self_team.size()

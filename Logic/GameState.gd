extends Node

class_name GameState

var Teams = {}
var FlagsLocations = {}
var ParentState = null

# sets the state before the current one
func SetparentState(state: GameState) -> void:
	ParentState = state
	pass

# sets the flag position for a team
func SetFlagLocation(team: String, pos: Vector2) -> void:
	if not team in FlagsLocations.keys():
		FlagsLocations[team] = pos
		pass
	pass

# sets the team and its ships
func SetTeam(team: String, ships: Array) -> void:
	if not team in  Teams.keys():
		Teams[team] == ships
		pass
	pass

# the average distance from a team to its flag
func DistanceAverageToSelfFlag(team: String) -> float:
	var distance = 0
	for soldier in Teams[team]:
		var vector: Vector2 = soldier.global_position - FlagsLocations[team]
		distance += vector.length_squared()
		pass
	return distance / Teams[team].size()

# the average distance from a team to the flag of another team
func DistanceAverageFromTeamToFlag(self_team: String,other_team: String) -> float:
	var distance = 0
	for soldier in Teams[self_team]:
		var vector: Vector2 = soldier.global_position - FlagsLocations[other_team]
		distance += vector.length_squared()
		pass
	return distance / Teams[self_team].size()

# the numbers of ships defending the flag of a given team
func GetFlagDefenders(team: String,defensive_perimeter: int) -> int:
	var defenders = 0
	for soldier in Teams[team]:
		var vector: Vector2 = soldier.global_position - FlagsLocations[team]
		if vector.length_squared() <= defensive_perimeter:
			defenders += 1
			pass
		pass
	return defenders

# the min distance from one team to another
func GetMinDistanceFromTeamTo(self_team: String,other_team: String) -> float:
	var distance_vector: Vector2 = Teams[self_team][0].global_position - Teams[other_team][0].global_position
	var distance = distance_vector.length_squared()
	for self_soldier in Teams[self_team]:
		for other_soldier in Teams[other_team]:
			distance_vector = self_soldier.global_position - other_soldier.global_position
			if distance_vector.length_squared() < distance:
				distance = distance_vector.length_squared()
				pass 
			pass
		pass
	return distance

# the min disvantage from one team to another team based in the diference of ships enemys
# that the ships sees and the allys closers
func DisvantageFromTeamTo(self_team: String, other_team: String,safe_distance: float) -> int:
	var disvantage = 0
	for soldier in Teams[self_team]:
		var soldier_disvantage = 1
		for ship in soldier.EnemysSeen:
			if ship.TEAM == other_team:
				soldier_disvantage -= 1
				pass
			pass
		for ally in Teams[self_team]:
			if not ally == soldier:
				var vector_distance: Vector2 = soldier.global_position - ally.global_position
				var distance = vector_distance.length_squared()
				if distance < safe_distance:
					soldier_disvantage -= 1
					pass
				pass
			pass
		if soldier_disvantage < disvantage:
			disvantage = soldier_disvantage
			pass
		pass
	return disvantage

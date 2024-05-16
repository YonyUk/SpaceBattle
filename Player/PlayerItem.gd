extends Area2D

var IDS = AreasIDS.new()
var ID = IDS.UserID
var TEAM = IDS.UserTeam
var BLOCKS_SIZE = 1
var OFFSET_POSITION = Vector2()
var GameMap = null

func SetGameParameters(blocks_size:int,offset_position: Vector2) -> void:
	BLOCKS_SIZE = blocks_size
	OFFSET_POSITION = offset_position
	pass

func SetGameMap(map:Map):
	GameMap = map
	pass


func GetBussyCells():
	var result := []
	var directions = [-1,0,1]
	var discrete_position = Vector2(int(global_position.x / BLOCKS_SIZE),int(global_position.y / BLOCKS_SIZE))
	for i in range(directions.size()):
		for j in range(directions.size()):
			var pos = discrete_position + Vector2(directions[i],directions[j])
			if GameMap.IsInRange(pos.x,pos.y):
				result.append(pos)
				pass
			pass
		pass
	return result

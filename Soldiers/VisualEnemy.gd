extends VisualSoldier

class_name VisualEnemy

func _ready():
	soldierItem = $EnemyItem
	Body = $Body
	VisionRange = sqrt(($EnemyItem/ShipDirector.global_position - global_position).length_squared())
	Radar = $ShipRadar
	ID = IDS.SoldierID
	TEAM = IDS.EnemyTeam
	pass

## New changes
func _on_VisualEnemy_body_entered(body):
	var bussy_cells = []
	if body.ID == IDS.UserID:
		bussy_cells = body.GetBussyCells()
		GameMap.SetBussyCells(bussy_cells)
		pass
	Core.Flank(soldierItem,VisionRange,GameMap)
	GameMap.FreeBussyCells(bussy_cells)
	pass # Replace with function body.

func _on_VisualEnemy_area_entered(area):
	var IsShip = area.ID == IDS.SoldierID or area.ID == IDS.CommandID
	if ShipsCollision and IsShip and area > self:
		var bussy_cells = area.GetBussyCells()
		GameMap.SetBussyCells(bussy_cells)
		SetTargetPosition(TargetPosition)
		GameMap.FreeBussyCells(bussy_cells)
		pass
	pass # Replace with function body.

func _on_ShipRadar_ShipDetected(ship):
	var IsShip = ship.ID == IDS.SoldierID or ship.ID == IDS.CommandID or ship.ID == IDS.UserID
	if not ship == self and not ship == soldierItem and not ship.TEAM == TEAM and IsShip:
		EnemysSeen.append(ship)
		pass
	pass

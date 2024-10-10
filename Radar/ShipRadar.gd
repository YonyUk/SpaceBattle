extends Area2D

var ID = 'RADAR'
var TEAM = "RADAR"

signal ShipDetected(ship)
signal ShipRadarExited(ship)

func _on_ShipRadar_area_entered(area):
	emit_signal("ShipDetected",area)
	pass # Replace with function body.


func _on_ShipRadar_area_exited(area):
	emit_signal("ShipRadarExited",area)
	pass # Replace with function body.

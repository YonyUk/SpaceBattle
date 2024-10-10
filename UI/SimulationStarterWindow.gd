extends WindowDialog

signal start

var map = ''
var MapLoad = false

func _on_START_pressed():
	emit_signal("start")
	hide()
	pass # Replace with function body.


func _on_Load_Map_pressed():
	$MapsLoader.show()
	$MapsLoader.popup_centered()
	pass # Replace with function body.


func _on_MapsLoader_file_selected(path):
	map = path
	$MapsLoader.hide()
	MapLoad = true
	pass # Replace with function body.

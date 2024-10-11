extends WindowDialog

signal start
signal save_results
signal loop(state)
signal loop_count(count)

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


func _on_SaveResults_pressed():
	emit_signal("save_results")
	pass # Replace with function body.


func _on_OnLoop_pressed():
	emit_signal("loop",$OnLoop.pressed)
	if $OnLoop.pressed:
		$OnLoop/on_loop_value.editable = true
		pass
	else:
		$OnLoop/on_loop_value.editable = false
		pass
	pass

func _on_on_loop_value_value_changed(value):
	emit_signal("loop_count",$OnLoop/on_loop_value.value)
	pass # Replace with function body.

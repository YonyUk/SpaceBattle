extends WindowDialog

signal start

func _on_START_pressed():
	emit_signal("start")
	hide()
	pass # Replace with function body.

extends Control

signal stop

func _on_Stop_pressed():
	emit_signal("stop")
	pass # Replace with function body.

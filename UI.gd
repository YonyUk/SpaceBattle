extends Control

signal Up()
signal Down()
signal UpReleased()
signal DownReleased()
signal Left()
signal LeftReleased()
signal Right()
signal RightReleased()

func _on_UpButton_pressed():
	emit_signal("Up")
	pass # Replace with function body.


func _on_DownButton_pressed():
	emit_signal("Down")
	pass # Replace with function body.



func _on_UpButton_released():
	emit_signal("UpReleased")
	pass # Replace with function body.


func _on_DownButton_released():
	emit_signal("DownReleased")
	pass # Replace with function body.


func _on_LeftButton_pressed():
	emit_signal("Left")
	pass # Replace with function body.


func _on_LeftButton_released():
	emit_signal("LeftReleased")
	pass # Replace with function body.


func _on_RightButton_pressed():
	emit_signal("Right")
	pass # Replace with function body.


func _on_RightButton_released():
	emit_signal("RightReleased")
	pass # Replace with function body.

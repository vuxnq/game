extends CanvasLayer

func _on_PlayButton_pressed():
	get_tree().change_scene("res://scenes/world.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()

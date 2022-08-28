extends CanvasLayer

func _ready():
	disable()

func _process(delta):
	pass

func enable():
	visible = true
	get_tree().paused = true

func disable():
	visible = false
	get_tree().paused = false

func _on_ContinueButton_pressed():
	disable()

func _on_QuitButton_pressed():
	get_tree().quit()

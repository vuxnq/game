extends CanvasLayer

var slowmo = false

func _ready():
	visible = false

func _process(delta):
	if slowmo == true:
		Engine.time_scale -= 2 * delta
		if Engine.time_scale < 0.1:
			get_tree().paused = true

func enable():
	visible = true
	slowmo = true

func _on_Button_pressed():
	visible = false
	slowmo = false
	Engine.time_scale = 1
	get_tree().paused = false
	get_tree().reload_current_scene()

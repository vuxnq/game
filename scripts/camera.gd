extends Camera2D

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				BUTTON_WHEEL_UP:
					if self.zoom > Vector2(0.5, 0.5):
						self.zoom -= Vector2(0.1, 0.1)
				BUTTON_WHEEL_DOWN:
					if self.zoom < Vector2(2,2):
						self.zoom += Vector2(0.1, 0.1)

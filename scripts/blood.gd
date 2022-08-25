extends CPUParticles2D

var fadeout = false

func _ready():
	self.emitting = true
	z_index = 1

func _process(delta):
	if fadeout == true:
		modulate.a -= 1 * delta
		if modulate.a < 0:
			queue_free()

func _on_Timer_timeout():
	fadeout = true

func _on_ZIndexTimer_timeout():
	z_index = 0

extends CanvasLayer

var health
var ammo

func _process(delta):
	$Health/HealthLabel.text = str(health)
	$Ammo/AmmoLabel.text = str(ammo)

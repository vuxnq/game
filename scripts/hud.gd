extends CanvasLayer

var health
var ammo
var reload = false

func _ready():
	visible = false

func _process(delta):
	$Health/HealthLabel.text = str(health)
	$Ammo/AmmoLabel.text = str(ammo)
	if reload == true:
		$ReloadLabel.visible = true
	else:
		$ReloadLabel.visible = false

extends Node2D

const bullet_path = preload("res://scenes/bullet.tscn")
var mouse_direction
var can_shoot
var delay = false

func _physics_process(_delta):
	mouse_direction = get_local_mouse_position().normalized()
	$Sprite.position.x = 3
	
	$Sprite.flip_v = false
	var gun_direction = get_global_mouse_position()
	if mouse_direction.x < 0:
		$Sprite.flip_v = true
		
	if mouse_direction.x < 0.5 && mouse_direction.y > -0.5:
		$Sprite.position.x = -3
	$Sprite.look_at(gun_direction)
	
	if Input.is_action_just_pressed("mouse_left"):
		$GunAnimation.play("shoot")
		shoot()

func shoot():
	if can_shoot == true && delay == false:
		var bullet = bullet_path.instance()
		get_tree().current_scene.add_child(bullet) # instead of 'get_parent().add_child(bullet)' because diff scene
		bullet.position = $Sprite/Position2D.global_position
		bullet.velocity = mouse_direction
		delay = true

func _on_GunAnimation_animation_finished(shoot):
	delay = false

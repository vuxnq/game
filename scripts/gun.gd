extends Node2D

onready var gun_texture = preload("res://assets/gun.png")
onready var gun_empty_texture = preload("res://assets/gun_empty.png")
const bullet_path = preload("res://scenes/bullet.tscn")
var mouse_direction
var can_shoot
var delay = false
var ammo = 15

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
		shoot()
	if Input.is_action_just_pressed("r"):
		reload()

func reload():
	ammo = 15
	$GunAnimation.play("reload")
	
func shoot():
	if can_shoot == true && delay == false && ammo > 0:
		ammo -= 1
		$GunAnimation.play("shoot")
		var bullet = bullet_path.instance()
		get_tree().current_scene.add_child(bullet) # instead of 'get_parent().add_child(bullet)' because diff scene
		bullet.position = $Sprite/Position2D.global_position
		bullet.velocity = mouse_direction
		delay = true
	elif ammo < 1:
		$GunAnimation.play("ghost")

func _on_GunAnimation_animation_finished(shoot):
	$GunAnimation.play("RESET")
	delay = false
	if ammo > 0:
		$Sprite.texture = gun_texture
	else:
		$Sprite.texture = gun_empty_texture

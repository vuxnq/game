extends KinematicBody2D

var acceleration := 800
var friction := 1000

var health = 100

var velocity := Vector2.ZERO
var speed
var mouse_direction
var input_vector
var can_shoot = true

signal player_position

onready var damage_timer = $DamageTimer
onready var animation_tree := $AnimationTree
onready var player_sprite := $YSort/Sprite
onready var player_texture = preload("res://assets/texture/player.png")
onready var player_nohand_texture = preload("res://assets/texture/player_nohand.png")

onready var blood_hit_path = preload("res://scenes/effects/blood_hit.tscn")
onready var blood_death_path = preload("res://scenes/effects/blood_death.tscn")

enum {
	UNARMED,
	AIM,
}

var state = UNARMED

func _ready():
	animation_tree.active = true
	damage_timer.connect("timeout", self, "take_damage")

func _physics_process(delta):
	Hud.health = health	
	movement(delta)
	match state:
		UNARMED:
			unarmed(delta)
		AIM:
			aim(delta)

func movement(delta):
	input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	velocity = move_and_slide(velocity)
	emit_signal("player_position", self.position)

func unarmed(delta):
	speed = 90
	player_sprite.texture = player_texture
	
	$Camera2D.offset = $Camera2D.offset.move_toward(Vector2.ZERO, 1000 * delta)
	
	if input_vector != Vector2.ZERO:
		animation_tree.get("parameters/playback").travel("walk")
		animation_tree.set("parameters/idle/blend_position", input_vector)
		animation_tree.set("parameters/walk/blend_position", input_vector)
		animation_tree.set("parameters/run/blend_position", input_vector)
		if Input.is_action_pressed("shift"):
				animation_tree.get("parameters/playback").travel("run")
				speed = 170
	else:
		animation_tree.get("parameters/playback").travel("idle")
	
	$YSort/Gun.can_shoot = false
	$YSort/Gun.visible = false
	if Input.is_action_pressed("mouse_right"):
		state = AIM
		$AimAudio.play()
	if $YSort/Gun.reload == true:
		aim(delta)

func aim(delta):
	speed = 80
	player_sprite.texture = player_nohand_texture
	
	mouse_direction = get_local_mouse_position().normalized()
	$Camera2D.offset = (get_global_mouse_position() - self.global_position) / 3
	$Camera2D.drag_margin_h_enabled = false
	$Camera2D.drag_margin_v_enabled = false
	
	animation_tree.set("parameters/idle/blend_position", mouse_direction)
	animation_tree.set("parameters/walk/blend_position", mouse_direction)
	animation_tree.set("parameters/run/blend_position", mouse_direction)
	
	if input_vector != Vector2.ZERO:
		if input_vector == mouse_direction.round().normalized(): # normal mouse_direction returns unfiltered and unnormalized values - must be rounded & normalized
			animation_tree.get("parameters/playback").travel("walk")
		else:
			animation_tree.get("parameters/playback").travel("walk") # should be moving backwards animation
			speed = 60
		if Input.is_action_pressed("shift"):
			if input_vector == mouse_direction.round().normalized():
				animation_tree.get("parameters/playback").travel("run")
				speed = 120
			else:
				animation_tree.get("parameters/playback").travel("walk") # should be running backwards animation
				speed = 100
	else:
		animation_tree.get("parameters/playback").travel("idle")
	
	$YSort/Gun.position = mouse_direction # 3d effect for gun and player using ysort
	$YSort/Gun.can_shoot = true
	$YSort/Gun.visible = true
	if not Input.is_action_pressed("mouse_right"):
		state = UNARMED
		$Camera2D.drag_margin_h_enabled = true
		$Camera2D.drag_margin_v_enabled = true


func _on_Hurtbox_body_entered(body):
	if body.is_in_group("enemy"):
		take_damage()
		damage_timer.start()
		
func _on_Hurtbox_body_exited(body):
	if body.is_in_group("enemy"):
		damage_timer.stop()

func take_damage():
	health -= 5
	var blood_hit = blood_hit_path.instance()
	blood_hit.position = self.global_position
	blood_hit.amount = 8
	blood_hit.initial_velocity = 80
	blood_hit.spread = 180
	get_tree().current_scene.add_child(blood_hit)
	if health < 1:
		health = 0
		damage_timer.stop()
		var blood_death = blood_death_path.instance()
		blood_death.position = self.position
		blood_death.amount = 128
		blood_death.spread = 180
		get_tree().current_scene.add_child(blood_death)
		DeathScreen.enable()

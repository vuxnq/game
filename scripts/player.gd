extends KinematicBody2D

var acceleration := 800
var friction := 1000

var velocity := Vector2.ZERO
var speed
var mouse_direction
var input_vector
var can_shoot = true

onready var animation_tree := $AnimationTree
onready var player_sprite := $YSort/Sprite
var player_texture = preload("res://assets/player.png")
var player_nohand_texture = preload("res://assets/player_nohand.png")

enum {
	UNARMED,
	AIM
}

var state = UNARMED

func _ready():
	animation_tree.active = true

func _physics_process(delta):
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



func unarmed(delta):
	speed = 90
	$Camera2D.offset = $Camera2D.offset.move_toward(Vector2.ZERO, 100 * delta)
	
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
	if Input.is_action_just_pressed("mouse_right"):
		state = AIM



func aim(delta):
	speed = 80
	player_sprite.texture = player_nohand_texture
	
	mouse_direction = get_local_mouse_position().normalized()
	$Camera2D.offset = $Camera2D.offset.move_toward(mouse_direction * 15, 100 * delta)
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
	if Input.is_action_just_released("mouse_right"):
		state = UNARMED
		player_sprite.texture = player_texture	
		$Camera2D.drag_margin_h_enabled = true
		$Camera2D.drag_margin_v_enabled = true

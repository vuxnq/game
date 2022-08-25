extends KinematicBody2D

onready var animation_tree := $AnimationTree
onready var timer = $FoolinAroundTimer
onready var blood_hit_path = preload("res://scenes/effects/blood_hit.tscn")
onready var blood_death_path = preload("res://scenes/effects/blood_death.tscn")
onready var damaged1_texture = preload("res://assets/enemy_damage1.png")
onready var damaged2_texture = preload("res://assets/enemy_damage2.png")

enum {
	IDLE,
	NEW_DIRECTION,
	MOVE
}

var player_detected = false
var player_position

var state = MOVE
var direction = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()
var velocity = Vector2.ZERO

var speed = 50
var acceleration = 1000
var friction = 1000

var health = 3
var bullet = preload("res://scenes/bullet.tscn")

func _ready():
	randomize()
	animation_tree.active = true
	
	var player = get_tree().get_root().find_node("Player", true, false)
	player.connect("player_position", self, "handle_player_position")

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		player_detected = true

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		player_detected = false

func _process(delta):
	match player_detected:
		true:
			chase()
		false:
			foolinaround()

func chase():
	speed = 100
	var player_direction = (player_position - self.position).normalized()
	animation_tree.get("parameters/playback").travel("run")
	animation_tree.set("parameters/run/blend_position", player_direction)
	velocity = Vector2.ZERO
	velocity = velocity.move_toward(speed * player_direction, acceleration)
	velocity = move_and_slide(velocity)
	
func foolinaround():
	speed = 50
	animation_tree.get("parameters/playback").travel("idle")
	animation_tree.set("parameters/idle/blend_position", direction)
	match state:
		IDLE:
			pass
		NEW_DIRECTION:
			direction = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()
			state = choose([IDLE,MOVE])
		MOVE:
			animation_tree.get("parameters/playback").travel("walk")
			animation_tree.set("parameters/walk/blend_position", direction)
			velocity = velocity.move_toward(speed * direction, acceleration)
			velocity = move_and_slide(velocity)

func _on_FoolinAroundTimer_timeout():
	timer.wait_time = rand_range(0,3)
	state = choose([IDLE,NEW_DIRECTION,MOVE])

func choose(array):
	array.shuffle()
	return array.front()

func handle_player_position(position):
	player_position = position

func _on_Hurtbox_body_entered(body):
	if body.is_in_group("bullet"):
		var hit_position = body.position
		take_damage(hit_position)
		body.queue_free()

func take_damage(hit_position):
	health -= 1
	player_detected = true
	var blood_hit = blood_hit_path.instance()
	blood_hit.position = hit_position
	blood_hit.rotation = global_position.angle_to_point(player_position)
	get_tree().current_scene.add_child(blood_hit)
	if health == 2:
		$Sprite.texture = damaged1_texture
	elif health == 1:
		$Sprite.texture = damaged2_texture
	elif health < 1:
		var blood_death = blood_death_path.instance()
		blood_death.position = hit_position
		blood_death.rotation = global_position.angle_to_point(player_position)
		get_tree().current_scene.add_child(blood_death)
		queue_free()

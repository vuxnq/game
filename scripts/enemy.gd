extends KinematicBody2D

onready var animation_tree := $AnimationTree
onready var timer = $Timer
onready var blood_hit_path = preload("res://scenes/effects/blood_hit.tscn")
onready var blood_death_path = preload("res://scenes/effects/blood_death.tscn")
onready var damaged1_texture = preload("res://assets/enemy_damage1.png")
onready var damaged2_texture = preload("res://assets/enemy_damage2.png")

enum {
	SEE,
	SEENT
}

var state = SEENT
var player_position
var random_direction
var health = 3
var bullet = preload("res://scenes/bullet.tscn")

func _ready():
	animation_tree.active = true
	
	var player = get_tree().get_root().find_node("Player", true, false)
	player.connect("player_position", self, "handle_player_position")

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		state = SEE

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		state = SEENT

func _process(delta):
	match state:
		SEE:
			see()
		SEENT:
			seent()

func see():
	var direction = (player_position - self.position).normalized()
	animation_tree.get("parameters/playback").travel("run")
	animation_tree.set("parameters/run/blend_position", direction)
	var velocity = Vector2.ZERO
	var speed = 100
	var acceleration = 1000
	velocity = velocity.move_toward(speed * direction, acceleration)
	move_and_slide(velocity)
	
func seent():
	animation_tree.get("parameters/playback").travel("idle")
	animation_tree.set("parameters/idle/blend_position", random_direction)

func handle_player_position(position):
	player_position = position

func _on_Timer_timeout():
	random_direction = Vector2(rand_range(-1, 1), rand_range(-1, 1))

func _on_Hurtbox_body_entered(body):
	if body.is_in_group("bullet"):
		var hit_position = body.position
		take_damage(hit_position)
		body.queue_free()

func take_damage(hit_position):
	health -= 1
	var blood_hit = blood_hit_path.instance()
	blood_hit.position = hit_position
	get_tree().current_scene.add_child(blood_hit)
	if health == 2:
		$Sprite.texture = damaged1_texture
	elif health == 1:
		$Sprite.texture = damaged2_texture
	elif health < 1:
		var blood_death = blood_death_path.instance()
		blood_death.position = hit_position
		get_tree().current_scene.add_child(blood_death)
		queue_free()

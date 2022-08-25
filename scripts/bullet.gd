extends KinematicBody2D

var velocity = Vector2(1, 0)
var speed = 800
var max_distance = 1000

var travelled_distance = 0

func _physics_process(delta):
	var _collision_info = move_and_collide(velocity * delta * speed)
	var distance = speed * delta
	
	travelled_distance += distance
	if travelled_distance > max_distance:
		queue_free()

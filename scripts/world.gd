extends Node

onready var enemy_path = preload("res://scenes/enemy.tscn")

func _process(delta):
	if Input.is_action_just_pressed("e"):
		var enemy = enemy_path.instance()
		get_tree().current_scene.get_node("YSort").add_child(enemy)

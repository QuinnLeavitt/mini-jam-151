extends Control

@onready var gold = $Gold:
	set(value):
		gold.text = "GOLD: " + str(value)

var uilife_scene = preload("res://ui/ui_life.tscn")

@onready var lives = $Lives

func init_lives(amount):
	for ul in lives.get_children():
		ul.queue_free()
	for i in amount:
		var ul = uilife_scene.instantiate()
		
		lives.add_child(ul)

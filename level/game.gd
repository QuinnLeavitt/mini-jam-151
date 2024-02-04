extends Node2D

@export var enemy_scenes: Array[PackedScene] = []

@onready var fire_blasts = $FireBlasts
@onready var player = $Player
@onready var enemy_container = $EnemyContainer

var enemy_budget = 0
var time_start = 0
var time_now = 0
var time_elapsed = 0

func _ready():
	time_start = Time.get_ticks_msec()
	$DragonTheme.play()

	player.connect("fire_breath", _on_player_fire_breathed)

func _process(delta):
	time_now = Time.get_ticks_msec()
	time_elapsed = time_now - time_start


	if Input.is_action_pressed("quit"):
		get_tree().quit()

func _on_player_fire_breathed(fireBlast):
	var fire_breath_sound = $FireBreathSound
	fire_breath_sound.set_pitch_scale(randf_range(0.7, 1.0))
	fire_breath_sound.play()
	fire_blasts.add_child(fireBlast)

func _on_enemy_fire_breathed(fireBlast):
	var fire_breath_sound = $FireBreathSound
	fire_breath_sound.set_pitch_scale(randf_range(0.7, 1.0))
	fire_breath_sound.play()
	fire_blasts.add_child(fireBlast)

func _on_enemy_died(dragon):
	var death_sound = $Kaching1
	death_sound.set_pitch_scale(randf_range(0.7, 1.0))
	death_sound.play()

func _on_enemy_spawn_timer_timeout():
	enemy_budget = (time_elapsed / 1000) - enemy_budget
	enemy_scenes.reverse()
	for enemy_scene in enemy_scenes:
		var e = enemy_scene.instantiate()
		if(enemy_budget > e.cost):
			e.global_position = Vector2(randf_range(50, 500), 50)
			e.connect("fire_breath", _on_enemy_fire_breathed)
			e.connect("died", _on_enemy_died)
			enemy_container.add_child(e)
			enemy_budget -= e.cost
		else: e.queue_free()
	print(enemy_budget)

extends Node2D

@export var enemy_scenes: Array[PackedScene] = []
@export var power_up_scenes: Array[PackedScene] = []
@export var power_up_chance = .15

@onready var fire_blasts = $FireBlasts
@onready var player = $Player
@onready var enemy_container = $EnemyContainer
@onready var power_up_container = $PowerUpContainer
@onready var hud = $UI/HUD
@onready var game_over_screen = $UI/GameOverScreen
@onready var pause_menu = $UI/PauseMenu
@onready var player_spawn_pos = $PlayerSpawnPos
@onready var only_once : bool = true

var enemy_budget = 200
var paused = false
var time_start = 0
var time_now = 0
var time_elapsed = 0

var gold := 0:
	set(value):
		gold = value
		hud.gold = gold
		
var lives: int:
	set(value):
		lives = value
		hud.init_lives(lives)

func _ready():
	time_start = Time.get_ticks_msec()
	game_over_screen.hide()
	pause_menu.hide()
	$DragonTheme.play()
	gold = 0
	lives = 3
	player.connect("fire_breath", _on_fire_breathed)
	player.connect("fire_sound", _on_fire_sound)
	player.connect("died", _on_player_died)
	player.connect("add_life", _on_add_life)
	player.connect("add_gold", _on_add_gold)

func _process(_delta):
	time_now = Time.get_ticks_msec()
	time_elapsed = time_now - time_start
	if gold < 0 && only_once:
		lives = 0
		_on_player_died()
		only_once = false

	if Input.is_action_just_pressed("pause") && lives > 0:
		pauseMenu()

func _on_fire_breathed(fireBlast):
	fire_blasts.add_child(fireBlast)

func _on_fire_sound():
	var fire_breath_sound = $FireBreathSound
	fire_breath_sound.set_pitch_scale(randf_range(0.7, 1.0))
	fire_breath_sound.play()

func _on_enemy_died(points, drag_pos):
	if player.is_alive:
		gold += points
	var death_sound = $DragonDeathSound
	death_sound.set_pitch_scale(randf_range(0.3, 2))
	death_sound.play()
	$Kaching1.play()
	if(randf() < power_up_chance):
		spawn_power_up(drag_pos)

func _on_player_died():
	lives -= 1
	player.global_position = player_spawn_pos.global_position
	if lives <= 0:
		$DragonDeathSound.play()
		await get_tree().create_timer(1).timeout
		game_over_screen.show()
	else:
		$DragonDeathSound.play()
		await get_tree().create_timer(1).timeout
		$StealGoldSound.play()
		if time_elapsed/1000 > 30:
			gold -= time_elapsed / 100
		elif time_elapsed/1000 > 60:
			gold -= time_elapsed / 100 * 2

		player.respawn(player_spawn_pos.global_position)

func _on_enemy_escaped(points):
	if gold > -1:
		if time_elapsed / 1000 > 30:
			gold -= points * 2
		elif time_elapsed / 1000 > 60:
			gold -= points * 4
		else:
			gold -= points
		$StealGoldSound.play()

func _on_enemy_spawn_timer_timeout():
	enemy_budget = gold - enemy_budget
	enemy_scenes.reverse()
	while(enemy_budget > 100):
		for enemy_scene in enemy_scenes:
			var e = enemy_scene.instantiate()
			if(enemy_budget >= e.cost):
				e.global_position = Vector2(randf_range(50, 500), -50)
				e.connect("fire_sound", _on_fire_sound)
				e.connect("fire_breath", _on_fire_breathed)
				e.connect("died", _on_enemy_died)
				e.connect("escaped", _on_enemy_escaped)
				enemy_container.add_child(e)
				enemy_budget -= e.cost
			else: e.queue_free()

func spawn_power_up(pos):
	var random_float = randf()
	if gold > 0 && random_float < 0.3:
		#spawn treasure+
		var p = power_up_scenes[0].instantiate()
		p.global_position = pos
		power_up_container.call_deferred("add_child", p)
	elif gold > 500 && random_float < .5:
		#spawn 1 up
		var p = power_up_scenes[1].instantiate()
		p.global_position = pos
		power_up_container.call_deferred("add_child", p)
	elif gold > 1000 && random_float < .7:
		#spawn health
		var p = power_up_scenes[2].instantiate()
		p.global_position = pos
		power_up_container.call_deferred("add_child", p)
	elif gold > 2000 && random_float < .85:
		#spawn damage up
		var p = power_up_scenes[4].instantiate()
		p.global_position = pos
		power_up_container.call_deferred("add_child", p)
	elif gold > 2500 && random_float < 1:
		#spawn additional fire blast
		var p = power_up_scenes[3].instantiate()
		p.global_position = pos
		power_up_container.call_deferred("add_child", p)
	else:
		#spawn treasure if other options weren't available
		var p = power_up_scenes[0].instantiate()
		p.global_position = pos
		power_up_container.call_deferred("add_child", p)
func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
	paused = !paused

func _on_add_life():
	lives += 1

func _on_add_gold():
	gold += 1000

extends Node2D

@export var enemy_scenes: Array[PackedScene] = []

@onready var fire_blasts = $FireBlasts
@onready var player = $Player
@onready var enemy_container = $EnemyContainer
@onready var hud = $UI/HUD
@onready var game_over_screen = $UI/GameOverScreen
@onready var pause_menu = $UI/PauseMenu
@onready var player_spawn_pos = $PlayerSpawnPos
@onready var only_once : bool = true

var paused = false
var enemy_budget = 0
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
	player.connect("fire_breath", _on_player_fire_breathed)
	player.connect("died", _on_player_died)

func _process(delta):
	time_now = Time.get_ticks_msec()
	time_elapsed = time_now - time_start
	if gold < 0 && only_once:
		lives = 0
		_on_player_died()
		only_once = false

	if Input.is_action_just_pressed("pause") && lives > 0:
		pauseMenu()

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

func _on_enemy_died(points):
	if player.is_alive:
		gold += points
	var death_sound = $DragonDeathSound
	death_sound.set_pitch_scale(randf_range(0.3, 2))
	death_sound.play()
	$Kaching1.play()

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
		player.respawn(player_spawn_pos.global_position)

func _on_enemy_escaped(points):
	if gold > -1:
		gold -= points
		$EnemyDeathSound.play()

func _on_enemy_spawn_timer_timeout():
	enemy_budget = (time_elapsed / 1000) - enemy_budget
	enemy_scenes.reverse()
	for enemy_scene in enemy_scenes:
		var e = enemy_scene.instantiate()
		if(enemy_budget > e.cost):
			e.global_position = Vector2(randf_range(50, 500), -50)
			e.connect("fire_breath", _on_enemy_fire_breathed)
			e.connect("died", _on_enemy_died)
			e.connect("escaped", _on_enemy_escaped)
			enemy_container.add_child(e)
			enemy_budget -= e.cost
		else: e.queue_free()

func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
	paused = !paused

class_name Player extends CharacterBody2D

signal fire_breath(breathe_fire)
signal fire_sound()
signal died
signal add_life
signal add_gold

@export var damage = 50
@export var fire_rate := 0.25
@export var SPEED = 350.0
@export var projectile_count = 1
@export var health = 25

@onready var mouth = $Mouth
@onready var sprite = $DragonAnimation
@onready var cshape = $CollisionShape2D

var shoot_cd = false
var is_alive = true
var is_invincible = false

var projectile_scene = preload("res://player/fire_projectile.tscn")

func _physics_process(_delta):
	if !is_alive: return
	#if Input.is_action_pressed("shoot"):
	if !shoot_cd:
		shoot_cd = true
		breathe_fire()
		await get_tree().create_timer(fire_rate).timeout
		shoot_cd = false
	var direction = Vector2(Input.get_axis("left", "right") ,Input.get_axis("up", "down"))
	if direction:
		velocity = direction * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		velocity.x = move_toward(velocity.x, 0, SPEED)
	$DragonAnimation.play()
	var animationSpeed = $DragonAnimation.get_playing_speed()
	if velocity.x == 0 && velocity.y == 0:
		$DragonAnimation.play(&"", animationSpeed/1.5, false)
	else:
		$DragonAnimation.play(&"", animationSpeed, false)
	move_and_slide()
	var screen_size = get_viewport_rect().size

	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0
	global_position.y = clamp(global_position.y, 0,  screen_size.y)
func breathe_fire():
	var component_degrees = (180/projectile_count)/2
	var cumulative_degrees = 270
	for p in projectile_count:
		var projectile = projectile_scene.instantiate()
		cumulative_degrees += component_degrees
		projectile.global_position = mouth.global_position
		projectile.rotation_degrees = cumulative_degrees
		projectile.damage = damage
		projectile.source = self
		cumulative_degrees += component_degrees
		emit_signal("fire_breath", projectile)
	emit_signal("fire_sound")

func take_damage(damage_taken):
	if !is_invincible:
		health -= damage_taken
		if health <= 0:
			die()

func die():
	if (is_alive==true && !is_invincible):
		is_alive = false
		sprite.visible = false
		cshape.set_deferred("disabled", true)
		#decrease power ups
		if(projectile_count >= 3):
			projectile_count -= 2
		if(health > 25):
			health -= 25
		if(damage > 50):
			damage -= 50

		emit_signal("died")

func respawn(pos):
	if is_alive == false:
		is_alive = true
		global_position = pos
		sprite.visible = true
		cshape.set_deferred("disabled", false)
		is_invincible = true
		await get_tree().create_timer(2).timeout
		is_invincible = false

func power_up(power_up_value):
	match power_up_value:
		0:
			emit_signal("add_gold")
		1:
			emit_signal("add_life")
		2:
			health += 25
		3:
			projectile_count += 2
		4:
			damage += 50



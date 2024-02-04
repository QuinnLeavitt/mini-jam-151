class_name Player extends CharacterBody2D

signal fire_breath(breathe_fire)
signal died

@export var damage = 50
@export var fire_rate := 0.25
@export var SPEED = 300.0

@onready var mouth = $Mouth

var shoot_cd = false
var is_alive = true
var is_invincible = false

var projectile_scene = preload("res://player/fire_projectile.tscn")

func _physics_process(_delta):
	if Input.is_action_pressed("shoot"):
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
	$dragonAnimation.play()
	var animationSpeed = $dragonAnimation.get_playing_speed()
	if velocity.x == 0 && velocity.y == 0:
		$dragonAnimation.play(&"", animationSpeed/1.5, false)
	else:
		$dragonAnimation.play(&"", animationSpeed, false)
	move_and_slide()

func breathe_fire():
	var projectile = projectile_scene.instantiate()
	projectile.global_position = mouth.global_position
	projectile.rotation = rotation
	projectile.damage = damage
	emit_signal("fire_breath", projectile)

func die():
	if (is_alive==true && !is_invincible):
		is_alive = false
		emit_signal("died")
		queue_free()

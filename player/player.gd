class_name Player extends CharacterBody2D

signal fire_breath(breathe_fire)
signal died

@export var damage = 50
@export var fire_rate := 0.25
@export var SPEED = 300.0

@onready var mouth = $Mouth
@onready var sprite = $DragonAnimation
@onready var cshape = $CollisionShape2D

var shoot_cd = false
var is_alive = true
var is_invincible = false

var projectile_scene = preload("res://player/fire_projectile.tscn")

func _physics_process(_delta):
	if !is_alive: return
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
	$DragonAnimation.play()
	var animationSpeed = $DragonAnimation.get_playing_speed()
	if velocity.x == 0 && velocity.y == 0:
		$DragonAnimation.play(&"", animationSpeed/1.5, false)
	else:
		$DragonAnimation.play(&"", animationSpeed, false)
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
		sprite.visible = false
		cshape.set_deferred("disabled", true)
		emit_signal("died")

func respawn(pos):
	if is_alive == false:
		is_alive = true
		global_position = pos
		sprite.visible = true
		cshape.set_deferred("disabled", false)

extends CharacterBody2D

signal fire_breath(breathe_fire)

@export var fire_rate := 0.15
@onready var mouth = $Mouth
const SPEED = 300.0
var shoot_cd = false
var projectile_scene = preload("res://player/fire_projectile.tscn")

func _physics_process(_delta):
	if Input.is_action_pressed("shoot"):
		if !shoot_cd:
			shoot_cd = true
			breathe_fire()
			await get_tree().create_timer(fire_rate).timeout
			shoot_cd = false
	var yDirection = Input.get_axis("up", "down")
	if yDirection:
		velocity.y = yDirection * SPEED
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED)
	var xDirection = Input.get_axis("left", "right")
	if xDirection:
		velocity.x = xDirection * SPEED
	else:
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
	emit_signal("fire_breath", projectile)

class_name Enemy extends Area2D

signal fire_breath(breathe_fire)
signal died

@export var speed = 150
@export var fire_rate := 0.25
@export var health = 40

@onready var mouth = $Mouth
var shoot_cd = false
var projectile_scene = preload("res://player/fire_projectile.tscn")
var is_alive = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$FodderDragAnim.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position.y += speed * delta
	if !shoot_cd:
		shoot_cd = true
		#breathe_fire()
		await get_tree().create_timer(fire_rate).timeout
		shoot_cd = false
	
#func breathe_fire():
	#var projectile = projectile_scene.instantiate()
	#projectile.global_position = mouth.global_position
	#projectile.rotation = rotation
	#emit_signal("fire_breath", projectile)
func take_damage(damage):
	health -= damage
	if health <= 0:
		die()

func die():
	if (is_alive==true):
		emit_signal("died")
		queue_free()

func _on_body_entered(body):
	if body is Player:
		var playerBody = body
		print("player ded")
		#playerBody.die()

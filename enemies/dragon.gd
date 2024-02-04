class_name Enemy extends Area2D

signal fire_breath(breathe_fire)
signal died(points)
signal escaped(points)

@export var speed = 250
@export var fire_rate = 3
@export var health = 50
@export var projectile_count = 1
@export var cost = 1
@export var point_value = 100

@onready var mouth = $Mouth

var projectile_scene = preload("res://player/fire_projectile.tscn")
var shoot_cd = false
var is_alive = true

func _ready():
	$FodderDragAnim.play()

func _process(delta):
	global_position.y += speed * delta
	if !shoot_cd:
		shoot_cd = true
		breathe_fire()
		await get_tree().create_timer(fire_rate).timeout
		shoot_cd = false
	
func breathe_fire():
	if projectile_count > 1:
		projectile_count = randi_range(projectile_count-2, projectile_count)
	var component_degrees = (mouth.rotation_degrees/projectile_count)/2
	var cumulative_degrees = 90
	for p in projectile_count:
		var projectile = projectile_scene.instantiate()
		#print(projectile)
		cumulative_degrees += component_degrees
		projectile.global_position = mouth.global_position
		projectile.rotation_degrees = cumulative_degrees
		emit_signal("fire_breath", projectile)
		cumulative_degrees += component_degrees

func take_damage(damage):
	health -= damage
	if health <= 0:
		die()

func die():
	if (is_alive==true):
		emit_signal("died", point_value)
		queue_free()

func _on_body_entered(body):
	if body is Player:
		var player_body = body
		player_body.die()

func _on_visible_on_screen_notifier_2d_screen_exited():
	emit_signal("escaped", point_value)
	queue_free()

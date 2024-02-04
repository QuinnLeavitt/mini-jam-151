extends Area2D

@export var speed = 500
@export var damage = 20
var movement_vector = Vector2(0, -1)

func _ready():
	print("firespawned")
	$AnimationPlayer.play("beginning_fire")
	$AnimationPlayer.queue("end_fire")

func _process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta

func _on_area_entered(area):
	if area is Enemy:
		var enemy = area
		print("Enemy hit")
		enemy.take_damage(damage)
		queue_free()
func _on_body_entered(body):
	if body is Player:
		var playerBody = body
		print("player ded")
		playerBody.die()

func _on_visible_on_screen_notifier_2d_screen_exited():
	print("deletefire")
	queue_free()

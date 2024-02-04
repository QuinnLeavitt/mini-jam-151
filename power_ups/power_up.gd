extends Area2D

@export var speed = 150
@export var power_up: int

func _process(delta):
	global_position.y += speed * delta

func _on_body_entered(body):
	if body is Player:
		var playerBody = body
		playerBody.power_up(power_up)
		queue_free()
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_life_span_timeout():
	queue_free()

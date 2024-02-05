extends Area2D

@export var speed = 500
@export var damage = 20
@export var source :Node
var movement_vector = Vector2(0, -1)

func _ready():

	if(source is Enemy):
		$AnimationPlayer.queue("end_fire")
		$Sprite2D.modulate = Color(.65, .5, 1)
		set_collision_mask_value(1,1)
	else:
		$AnimationPlayer.play("beginning_fire")
		$AnimationPlayer.queue("end_fire")
		set_collision_mask_value(2, 1)
func _process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta

func _on_area_entered(area):
	if area is Enemy:
		var enemy = area
		enemy.take_damage(damage)
		queue_free()

func _on_body_entered(body):
	if body is Player:
		var playerBody = body
		playerBody.take_damage(damage)
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

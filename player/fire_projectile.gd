extends Area2D

@export var speed := 300.0
@onready var lifetime = $Lifetime
var movement_vector := Vector2(0, -1)

func _ready():
	$AnimationPlayer.play("beginning_fire")
	$AnimationPlayer.queue("end_fire")
	lifetime.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta
#func _on_visible_on_screen_notifier_2d_screen_exited():
	#queue_free()

#func _on_area_entered(area):
	#if area is Enemy:
		#var Enemy = area
		#Enemy.explode()
		#queue_free()


func _on_lifetime_timeout():
	queue_free()

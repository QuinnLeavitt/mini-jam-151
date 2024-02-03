extends Node2D

@onready var fireBlasts = $FireBlasts
@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("fire_breath", _on_player_fire_breathed)
	$DragonTheme.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("quit"):
		get_tree().quit()

func _on_player_fire_breathed(fireBlast):
	var fireBreathSound = $FireBreathSound
	fireBreathSound.set_pitch_scale(randf_range(0.7, 1.0))
	fireBreathSound.play()
	fireBlasts.add_child(fireBlast)

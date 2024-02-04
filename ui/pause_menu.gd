extends Control

@onready var main = $"../../"

func _on_restart_pressed():
	get_tree().reload_current_scene


func _on_resume_pressed():
	main.pauseMenu()

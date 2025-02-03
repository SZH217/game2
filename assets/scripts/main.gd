extends Control
const WORLD = preload("res://assets/scenes/world.tscn")


func _on_start_pressed() -> void:
	var game_scene = WORLD
	get_tree().change_scene_to_file(game_scene)

func _on_options_pressed() -> void:
	$settings.visible = true


func _on_quit_pressed() -> void:
	get_tree().quit()

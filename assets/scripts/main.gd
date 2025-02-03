extends Control
const WORLD = preload("res://assets/scenes/world.tscn")


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(WORLD.resource_path)


func _on_options_pressed() -> void:
	$settings.visible = true


func _on_quit_pressed() -> void:
	get_tree().quit()

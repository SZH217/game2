extends Control

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		visible = true

func _on_continue_pressed() -> void:
	visible = false


func _on_options_pressed() -> void:
	$settings.visible = true


func _on_quit_pressed() -> void:
	var mainMenu = "res://assets/scenes/main.tscn"
	get_tree().change_scene_to_file(mainMenu)

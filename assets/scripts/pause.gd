extends Control

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		visible = true
	if visible:
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if !visible:
		get_tree().paused = false

func _on_continue_pressed() -> void:
	visible = false


func _on_options_pressed() -> void:
	$settings.visible = true
	$Panel.visible = false


func _on_quit_pressed() -> void:
	var mainMenu = "res://assets/scenes/main.tscn"
	get_tree().change_scene_to_file(mainMenu)


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()


func _on_close_pressed() -> void:
	$Panel.visible = true

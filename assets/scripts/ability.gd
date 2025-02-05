extends Control

@export var current = 1


func _on_up_mouse_entered() -> void:
	current = 2
	$TextureRect/MarginContainer/up.custom_minimum_size = Vector2(130, 130)


func _on_down_mouse_entered() -> void:
	current = 4
	$TextureRect/MarginContainer/down.custom_minimum_size = Vector2(130, 130)


func _on_left_mouse_entered() -> void:
	current = 1
	$TextureRect/MarginContainer/left.custom_minimum_size = Vector2(130, 130)


func _on_right_mouse_entered() -> void:
	current = 3
	$TextureRect/MarginContainer/right.custom_minimum_size = Vector2(130, 130)




func _on_up_mouse_exited() -> void:
	$TextureRect/MarginContainer/up.custom_minimum_size = Vector2(100, 100)


func _on_down_mouse_exited() -> void:
	$TextureRect/MarginContainer/down.custom_minimum_size = Vector2(100, 100)


func _on_left_mouse_exited() -> void:
	$TextureRect/MarginContainer/left.custom_minimum_size = Vector2(100, 100)


func _on_right_mouse_exited() -> void:
	$TextureRect/MarginContainer/right.custom_minimum_size = Vector2(100, 100)

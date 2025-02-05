extends Sprite2D

@export var scroll_speed: Vector2 = Vector2(0.05, 0.05)  # Slow down movement

func _process(delta):
	material.set_shader_parameter("offset", material.get_shader_parameter("offset") + (scroll_speed * delta))

extends Camera2D

@export var look_ahead_distance = 100.0
@export var smooth_factor = 0.03

func _process(_delta):
	var player = get_parent()

	if player != null:
		var look_ahead_offset = Vector2(look_ahead_distance * sign(player.velocity.x), 0)
		var target_position = player.global_position + look_ahead_offset

		global_position = global_position.lerp(target_position, smooth_factor)

extends Area2D

@export var player: Node
@export var max_speed: float = 800.0
@export var acceleration: float = 400.0
@export var return_speed: float = 600.0
@export var flash_interval: float = 0.1
@export var hand_speed: float = 550.0
@onready var hand_sprite = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_speed: float = 0.0
var is_returning: bool = false
var flash_timer: Timer
var is_flashing: bool = false
var original_modulate: Color

var hand_direction: Vector2 = Vector2.ZERO
@export var hand_returning: bool = false

func _ready():
	animation_player.play("handrocket")
	animation_player.get_animation("handrocket").loop = true
	original_modulate = modulate
	connect("body_entered", Callable(self, "_on_body_entered"))

	hand_sprite.flip_h = hand_direction.x < 0

	flash_timer = Timer.new()
	flash_timer.wait_time = flash_interval
	flash_timer.one_shot = false
	flash_timer.connect("timeout", Callable(self, "_on_flash_timeout"))
	add_child(flash_timer)

	current_speed = 0.0

func _process(delta: float) -> void:
	if not is_returning:
		if current_speed < max_speed:
			current_speed += acceleration * delta
			current_speed = min(current_speed, max_speed)
			if current_speed == max_speed and not is_flashing:
				is_flashing = true
				flash_timer.start()

		position += hand_direction * current_speed * delta
	else:
		var target_position = player.global_position + player.hand_launch_offset
		var direction_to_target = (target_position - global_position).normalized()
		position += direction_to_target * return_speed * delta

		if global_position.distance_to(target_position) < 10.0:
			is_returning = false
			is_flashing = false
			modulate = original_modulate

	if is_flashing and not is_returning:
		modulate = Color(1, 0, 0, sin(Time.get_ticks_msec() / 100.0) * 0.35 + 0.5)

func _on_flash_timeout() -> void:
	if is_flashing:
		if modulate.a == 0.5:
			modulate.a = 1.0
		else:
			modulate.a = 0.5

func _on_body_entered(body):
	if player and body != null:
		player.set_hand_returning(true)
		set_hand_returning(true)
		current_speed = 0.0
		is_flashing = false
		modulate = original_modulate

# Setter function for hand_returning
func set_hand_returning(value: bool) -> void:
	hand_returning = value
	is_returning = value

extends Area2D

@export var max_speed: float = 800.0
@export var acceleration: float = 400.0
@export var return_speed: float = 600.0
@export var hand_speed: float = 550.0
@export var return_distance: float = 300.0  # Максимальная дистанция до возврата

@onready var hand_sprite = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var player: CharacterBody2D
var hand_direction: Vector2 = Vector2.ZERO
var current_speed: float = 0.0
var is_returning: bool = false
var canGet = false
var getTime = 1

func _ready():
	animation_player.play("handrocket")
	hand_sprite.flip_h = hand_direction.x < 0
	add_to_group("hand_return")
	$Timer.start(getTime)

func _process(delta: float) -> void:
	if not is_returning:
		if current_speed < max_speed:
			current_speed += acceleration * delta
			current_speed = min(current_speed, max_speed)

		position += hand_direction * current_speed * delta
		if hand_direction.x < player.global_position.x:
			$Sprite2D.flip_h = false
		else:
			$Sprite2D.flip_h = true
		rotation = hand_direction.angle()

		if global_position.distance_to(player.global_position) > return_distance:
			is_returning = true
	else:
		var target_position = player.global_position
		var direction_to_target = (target_position - global_position).normalized()
		position += direction_to_target * return_speed * delta
	
	if is_returning:
		canGet = true
	

func _on_body_entered(body):
	if body != player:
		is_returning = true
	if body == player and canGet:
		get_tree().call_group("hand_return", "on_hand_returned")
		queue_free()


func _on_timer_timeout() -> void:
	canGet = true

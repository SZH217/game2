extends Area2D

@export var max_speed: float = 1.0
@export var acceleration: float = 1.0
@export var return_speed: float = 1.0
@export var return_distance: float = 100.0  # Максимальная дистанция до возврата

@onready var hand_sprite = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var player: CharacterBody2D
var hand_direction: Vector2 = Vector2.ZERO
var current_speed: float = 800.0
var is_returning: bool = false
var canGet = false
var getTime = 0.2

func _ready():
	animation_player.play("handrocket")
	hand_sprite.flip_h = hand_direction.x < 0
	add_to_group("hand_return")
	$Timer.start(getTime)

func _process(delta: float) -> void:
	if not is_returning:
		if current_speed < max_speed:
			current_speed += acceleration * delta

		position += hand_direction * current_speed * delta

		# Flip the sprite based on the direction
		if hand_direction.x < 0:
			hand_sprite.flip_v = true
			hand_sprite.flip_h = false

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
	
	if body.name.begins_with('enemy'):
		body.getHit(20, global_position)
	elif body.name.begins_with('boss'):
		body.getHit(20)

func _on_timer_timeout() -> void:
	canGet = true

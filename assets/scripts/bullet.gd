extends Area2D

@export var speed: float = 600  # Bullet speed
@onready var player = $"../player"

var direction: Vector2 = Vector2.ZERO  # Bullet movement direction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player:
		direction = (player.global_position - global_position).normalized()
		rotation = direction.angle()  # Rotate the bullet sprite based on direction
	$Timer.start(3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player.takehit(10)
		queue_free()  # Destroy bullet on hit

func _on_timer_timeout() -> void:
	queue_free()  # Destroy bullet after 3 seconds

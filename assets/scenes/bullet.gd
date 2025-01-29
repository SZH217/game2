extends Area2D

@export var speed: float = 300  # Скорость пули
@onready var player = $"../player"

var direction: Vector2 = Vector2.ZERO  # Направление движения пули

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player:
		direction = (player.global_position - global_position).normalized()
	$Timer.start(3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		print("hit")
		queue_free()  # Уничтожаем пулю при попадании в игрока

func _on_timer_timeout() -> void:
	queue_free()  # Уничтожаем пулю через 3 секунды

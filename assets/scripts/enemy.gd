extends RigidBody2D

@export var speed = 20
@export var maxSpeed = 200
var playerHere = false
@onready var player = $"../player"
var gravity = 20
var playerClose = false

var backspeed = 5
var maxbackspeed = 100

@export var bullet: PackedScene  # Убедитесь, что это назначено в инспекторе
var can_shoot = true  # Флаг для контроля стрельбы

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playerHere:
		shoot()
	if playerHere and !playerClose:
		if player.global_position.x > position.x:
			if linear_velocity.x < maxSpeed:
				linear_velocity.x += speed
		elif player.global_position.x < position.x:
			if linear_velocity.x > -maxSpeed:
				linear_velocity.x -= speed
	elif playerHere and playerClose:
		if player.global_position.x > position.x:
			if linear_velocity.x < maxbackspeed:
				linear_velocity.x -= backspeed
		elif player.global_position.x < position.x:
			if linear_velocity.x > -maxbackspeed:
				linear_velocity.x += backspeed

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		playerHere = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		playerHere = false

func _on_close_area_body_entered(body: Node2D) -> void:
	if body.name == "player":
		playerClose = true

func _on_close_area_body_exited(body: Node2D) -> void:
	if body.name == "player":
		playerClose = false

func shoot():
	if not can_shoot:  # Используем флаг can_shoot вместо функции shoot
		return

	# Создаем экземпляр пули
	var bulletInst = bullet.instantiate()

	# Вычисляем направление от врага к игроку
	var direction = (player.global_position - global_position).normalized()

	# Устанавливаем позицию пули
	var launch_distance = 40.0
	var launch_position = global_position + direction * launch_distance
	bulletInst.global_position = launch_position

	# Задаем скорость пули (используем linear_velocity для RigidBody2D)
	if bulletInst is RigidBody2D:
		bulletInst.linear_velocity = direction * 300  # Скорость пули

	# Добавляем пулю на сцену
	get_parent().call_deferred("add_child", bulletInst)

	# Устанавливаем задержку перед следующим выстрелом
	can_shoot = false
	await get_tree().create_timer(1.0).timeout  # Задержка 1 секунда
	can_shoot = true

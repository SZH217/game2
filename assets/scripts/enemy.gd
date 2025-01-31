extends RigidBody2D

@export var speed = 200
@export var maxSpeed = 200
var playerHere = false
@onready var player = $"../player"
var gravity = 20
var playerClose = false
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D  # Убедитесь, что у врага есть спрайт

var backspeed = 5
var maxbackspeed = 100

@export var bullet: PackedScene  # Убедитесь, что это назначено в инспекторе
var can_shoot = true  # Флаг для контроля стрельбы

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("idle")  # Устанавливаем анимацию по умолчанию

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playerHere and playerClose:
		anim.play("aim")  # Если игрок близко, переходим в анимацию aim
		shoot()
		# Определяем направление взгляда врага на игрока
		sprite.flip_h = player.global_position.x > position.x
		return
	
	if playerHere and not playerClose:
		if player.global_position.x > position.x:
			if linear_velocity.x < maxSpeed:
				linear_velocity.x += speed
				anim.play("run")  # Запускаем анимацию бега
				sprite.flip_h = true  # Отражаем спрайт вправо
		elif player.global_position.x < position.x:
			if linear_velocity.x > -maxSpeed:
				linear_velocity.x -= speed
				anim.play("run")  # Запускаем анимацию бега
				sprite.flip_h = false  # Оставляем спрайт по умолчанию (влево)
	else:
		anim.play("idle")  # Если нет движения, переходим в idle

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
	
	anim.play("aim")  # Запускаем анимацию стрельбы
	
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
		bulletInst.linear_velocity = direction * 500  # Скорость пули
	
	# Добавляем пулю на сцену
	get_parent().call_deferred("add_child", bulletInst)
	
	# Устанавливаем задержку перед следующим выстрелом
	can_shoot = false
	await get_tree().create_timer(0.5).timeout  # Задержка 1 секунда
	can_shoot = true

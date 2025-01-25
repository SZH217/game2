extends CharacterBody2D


@export var maxSpeed = 400
@export var speed = 40
@export var gravity = 20
@export var jumpForce = 500
@export var wallSpeed = 5
@export var cameraOffset = 50
@export var offsetSpeed = 2
@onready var animation_player = $anim

var haveHand = true
var jump = false
var wall = false
var walljump = false

var canShoot = false

@export var hand_scene: PackedScene  # Префаб руки

func _ready() -> void:
	add_to_group("hand_return")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if velocity.x < 0 and !wall:
		$sprite.flip_h = true
	if velocity.x > 0 and !wall:
		$sprite.flip_h = false
	
	if !jump and !wall:
		if is_on_floor():
			if velocity.x == 0:
				play_animation("idle")
			if velocity.x != 0:
				play_animation("running")
		else:
			if velocity.y > 0:
				play_animation("jump_fall")
			elif velocity.y < 0:
				play_animation("jump_rise")
	if jump:
		if velocity.y < 0:
			play_animation("jump_rise")
		if velocity.y > 0:
			play_animation("jump_fall")
		if is_on_floor():
			jump = false
	
	if wall:
		play_animation("wall")


func _physics_process(delta: float) -> void:
	if !is_on_floor() and !wall:
		velocity.y += gravity
	
	
	
	var navigation = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	
	if navigation == 1:
		if $camera.offset.x < cameraOffset:
			$camera.offset.x += offsetSpeed
		if velocity.x < maxSpeed:
			velocity.x += speed
	elif navigation == -1:
		if $camera.offset.x > -cameraOffset:
			$camera.offset.x -= offsetSpeed
		if velocity.x > -maxSpeed:
			velocity.x -= speed
	else:
		if $camera.offset.x != 0:
			if $camera.offset.x > 0:
				$camera.offset.x -= offsetSpeed
			if $camera.offset.x < 0:
				$camera.offset.x += offsetSpeed
		if velocity.x > 0:
			velocity.x -= speed / 4
		if velocity.x < 0:
			velocity.x += speed / 4
	
	if Input.is_action_just_pressed("action_c"):
		if is_on_floor():  # Прыжок с пола
			velocity.y = -jumpForce
		elif wall:  # Прыжок от стены
			velocity.y = -jumpForce
			velocity.x = maxSpeed * (1 if $left.is_colliding() else -1)  # Отталкивание в противоположную сторону
			walljump = false
			
	
	if $left.is_colliding() or $right.is_colliding():
		wall = true
		canShoot = false
		if !is_on_floor():  # Только если игрок не на полу
			velocity.y += wallSpeed  # Сбрасываем вертикальную скорость
			walljump = true
	else:
		wall = false
		canShoot = true

	
	if walljump:
		if Input.is_action_just_pressed("action_c"):
			walljump = false
	move_and_slide()
	
	if haveHand and canShoot and Input.is_action_just_pressed("action_attack"):
		launch_hand()
		haveHand = false
	
	
func play_animation(base_anim: String):
	if not animation_player:
		return
	var anim_suffix = "_nr" if !haveHand else ""
	var full_anim_name = base_anim + anim_suffix
	animation_player.play(full_anim_name)


func launch_hand():
	if not hand_scene:
		return
	var launch_distance = 50.0
	var hand_instance = hand_scene.instantiate()
	hand_instance.hand_direction = (get_global_mouse_position() - global_position).normalized()
	var launch_position = global_position + hand_instance.hand_direction * launch_distance
	hand_instance.global_position = launch_position
	hand_instance.player = self
	get_parent().add_child(hand_instance)
	

func on_hand_returned():
	haveHand = true

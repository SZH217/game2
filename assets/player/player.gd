extends CharacterBody2D

@export var maxSpeed = 500
@export var speed = 40
@export var gravity = 23
@export var jumpForce = 600
@export var jump_hold_factor = 0.4
@export var wallSpeed = 10
@export var maxWallSpeed = 80
@export var cameraOffset = 50
@export var offsetSpeed = 2
@onready var animation_player = $anim
var previous_velocity_y = 0.0

var haveHand = true
var jump = false
var wall = false
var walljump = false
var shootAnim = false
var canShoot = false
var isJumping = false  # Track if the player is currently jumping

@export var hand_scene: PackedScene  # Prefab for the hand

func _ready() -> void:
	add_to_group("hand_return")

func _process(delta: float) -> void:
	if velocity.x < 0 and !wall:
		$sprite.flip_h = true
	if velocity.x > 0 and !wall:
		$sprite.flip_h = false
	
	if !jump and !wall and !shootAnim:
		if is_on_floor():
			if velocity.x == 0:
				play_animation("idle")
			else:
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
	
	if shootAnim:
		animation_player.play("handattack")

func _physics_process(delta: float) -> void:
	if !is_on_floor() and !wall:
		velocity.y += gravity  # Apply normal gravity
	
	if is_on_floor():
		# Check if the player just landed and their previous Y velocity was greater than 450
		if previous_velocity_y > 450:
			$Land.play()  # Play the landing sound effect
		wall = false
		isJumping = false  # Reset jump state when touching the ground
	
	# Store the current Y velocity before applying movement
	previous_velocity_y = velocity.y
	
	var navigation = Input.get_action_strength("right") - Input.get_action_strength("left")

	# Horizontal movement
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
	
	# Jump logic with variable height
	if Input.is_action_just_pressed("action_c"):
		if is_on_floor():
			$Jump.play()
			velocity.y = -jumpForce
			isJumping = true  # Player is in the middle of a jump
		elif wall:
			velocity.y = -jumpForce
			velocity.x = maxSpeed * (1 if $left.is_colliding() else -1)
			walljump = false
			isJumping = true

	# Reduce jump height if button is released early
	if isJumping and Input.is_action_just_released("action_c") and velocity.y < 0:
		velocity.y *= jump_hold_factor  # Cut jump short

	# Wall slide mechanics
	if !is_on_floor():
		if $left.is_colliding() or $right.is_colliding():
			wall = true
			canShoot = false
			if velocity.y < maxWallSpeed:
				velocity.y += wallSpeed  # Apply wall sliding effect
				walljump = true
		else:
			wall = false
			canShoot = true
	
	if walljump:
		if Input.is_action_just_pressed("action_c"):
			walljump = false
	
	move_and_slide()
	
	# Hand attack mechanic
	if haveHand and canShoot and Input.is_action_just_pressed("action_attack"):
		$Attack.play()
		launch_hand()
		haveHand = false
		shootAnim = true

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

func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "handattack":
		shootAnim = false

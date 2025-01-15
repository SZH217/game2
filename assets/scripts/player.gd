extends CharacterBody2D

const MAX_SPEED = 450.0
const ACCELERATION = 1200.0
const DECELERATION = 800.0
const TURN_DECELERATION = 1100.0
const MIN_JUMP_VELOCITY = -225.0
const MAX_JUMP_VELOCITY = -425.0
const JUMP_HOLD_TIME = 0.2
const GRAVITY = 20.0
const WALL_SLIDE_SPEED = 100.0
const WALL_JUMP_HORIZONTAL_VELOCITY = 400.0
const WALL_JUMP_HAND_OUT_HORIZONTAL_VELOCITY = 350.0
const WALL_JUMP_VERTICAL_VELOCITY = -280.0
const WALL_JUMP_HAND_OUT_VERTICAL_VELOCITY = 200.0

const JUMP_HORIZONTAL_BOOST = 1.5
const JUMP_HORIZONTAL_REDUCE = 0.5
const HAND_OUT_SPEED_MULTIPLIER = 1.2
const WALL_SLIDE_HAND_OUT_MULTIPLIER = 2

@export var hand_scene: PackedScene

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var hand_ray_right = $HandRayRight
@onready var hand_ray_left = $HandRayLeft
@onready var audio_stream_player: AudioStreamPlayer = %bgm1

var last_direction = 0
var jump_pressed = false
var jump_time = 0.0
var was_in_air = false
var lastvely = 0

var hand_instance: Area2D = null
var hand_returning = false
var hand_launch_offset = Vector2.ZERO

var is_hand_flying = false
var has_played_landing_sound = false
var is_shooting = false
var is_hand_out = false
var is_wall_sliding = false

# Removed the selected_ability variable since it will now be accessed from GlobVars
@export var ability_picker_scene: PackedScene  # Drag the AbilityPicker.tscn here in the editor
var ability_picker_instance: Node = null
var is_ability_picker_active = false

@export var target_pitch: float = 0.25  # Target pitch scale when the action is pressed
@export var lerp_duration: float = 0.5  # Duration for pitch change

func set_hand_returning(value: bool) -> void:
	hand_returning = value

func _ready():
	# Ensure the audio player starts with a pitch of 1.0
	audio_stream_player.pitch_scale = 1.0
	GlobVars.selected_ability_name = "Hand Rocket"

func _physics_process(delta: float) -> void:
	# If action_pick is pressed, load and display the ability picker
	if Input.is_action_just_pressed("action_pick") and not is_ability_picker_active:
		# Slow down time (optional)
		Engine.time_scale = 0.5

		# Lower the pitch
		var tween = get_tree().create_tween()
		tween.tween_property(audio_stream_player, "pitch_scale", 0.5, 0.5)

		# Load the ability picker scene
		ability_picker_instance = ability_picker_scene.instantiate()
		
		if ability_picker_instance:
			get_tree().root.add_child(ability_picker_instance)

		# Set the ability picker state to active
		is_ability_picker_active = true

	# If action_pick is released, close the ability picker and restore normal conditions
	if Input.is_action_just_released("action_pick") and is_ability_picker_active:
		# Restore normal time scale
		Engine.time_scale = 1.0

		# Raise the pitch back to normal
		var tween = get_tree().create_tween()
		tween.tween_property(audio_stream_player, "pitch_scale", 1.0, 0.5)

		# Remove the ability picker from the scene
		ability_picker_instance.queue_free()
		ability_picker_instance = null

		# Set the ability picker state to inactive
		is_ability_picker_active = false
	# Handle gravity and landing
	if not is_on_floor() and not is_wall_sliding:
		velocity.y += GRAVITY
		if velocity.y != 0:
			lastvely = velocity.y
		was_in_air = true
	else:
		if was_in_air:
			if lastvely > 450 and not has_played_landing_sound:
				print("Landing sound triggered")
				$Land.play()
				has_played_landing_sound = true

			print("Landed")
			was_in_air = false
			is_shooting = false
		else:
			has_played_landing_sound = false

	if Input.is_action_pressed("restart"):
		GlobVars.musicProgress = audio_stream_player.get_playback_position()
		get_tree().reload_current_scene()
		return

	# Check if player is sliding on a wall
	var touching_wall = (hand_ray_right.is_colliding() or hand_ray_left.is_colliding()) and not is_on_floor()
	if touching_wall and velocity.y > 0:
		is_wall_sliding = true
		play_animation("wall")
		var slide_speed = WALL_SLIDE_SPEED
		if is_hand_out:
			slide_speed *= WALL_SLIDE_HAND_OUT_MULTIPLIER

		velocity.y = slide_speed
	else:
		is_wall_sliding = false

	var left_pressed = Input.is_action_pressed("left")
	var right_pressed = Input.is_action_pressed("right")
	var direction = 0

	if not is_shooting or is_wall_sliding:
		if left_pressed and right_pressed:
			direction = last_direction
		elif left_pressed:
			if not hand_ray_left.is_colliding() or is_wall_sliding:  # Allow movement even when near a wall if sliding
				direction = -1
				last_direction = direction
		elif right_pressed:
			if not hand_ray_right.is_colliding() or is_wall_sliding:  # Allow movement even when near a wall if sliding
				direction = 1
				last_direction = direction

		if direction != 0:
			var speed_multiplier = HAND_OUT_SPEED_MULTIPLIER if is_hand_out else 1.0
			var target_speed = direction * MAX_SPEED * speed_multiplier

			if sign(velocity.x) != sign(direction) and abs(velocity.x) > 0:
				velocity.x = move_toward(velocity.x, target_speed, TURN_DECELERATION * delta)
			else:
				velocity.x = move_toward(velocity.x, target_speed, ACCELERATION * delta)

			sprite.flip_h = direction < 0
			
			if is_on_floor() and not is_wall_sliding:
				play_animation("running")
		else:
			velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)

			if is_on_floor() and abs(velocity.x) < 5.0:
				play_animation("idle")
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)


	if last_direction < 0:
		hand_ray_left.enabled = true
		hand_ray_right.enabled = false
	else:
		hand_ray_left.enabled = false
		hand_ray_right.enabled = true

	if Input.is_action_just_pressed("action_c"):
		if is_wall_sliding:
			$Jump.play()
			jump_pressed = true
			jump_time = 0.0
			
			if is_hand_out:
				velocity.y = WALL_JUMP_HAND_OUT_VERTICAL_VELOCITY
				velocity.x = WALL_JUMP_HAND_OUT_HORIZONTAL_VELOCITY * -last_direction
			else:
				velocity.y = WALL_JUMP_VERTICAL_VELOCITY
				velocity.x = WALL_JUMP_HORIZONTAL_VELOCITY * -last_direction

			is_wall_sliding = false
			play_animation("jump_rise")

		elif is_on_floor():
			$Jump.play()
			jump_pressed = true
			jump_time = 0.0
			velocity.y = MIN_JUMP_VELOCITY
			was_in_air = true
			print("Jump initiated")

			if abs(velocity.x) > MAX_SPEED * 0.5:
				velocity.x *= JUMP_HORIZONTAL_BOOST
			else:
				velocity.x *= JUMP_HORIZONTAL_REDUCE

			play_animation("jump_rise")

	if jump_pressed and Input.is_action_pressed("action_c"):
		jump_time += delta
		if jump_time < JUMP_HOLD_TIME:
			velocity.y = lerp(MIN_JUMP_VELOCITY, MAX_JUMP_VELOCITY, jump_time / JUMP_HOLD_TIME)

	if Input.is_action_just_released("action_c"):
		jump_pressed = false

	if not is_on_floor() and not is_wall_sliding:
		if velocity.y < 0:
			play_animation("jump_rise")
		elif velocity.y > 0:
			play_animation("jump_fall")

	# Check for the selected ability using GlobVars
	if Input.is_action_just_pressed("action_attack"):
		var selected_ability = GlobVars.selected_ability_name  # Use GlobVars to get the selected ability
		if selected_ability == "Hand Rocket":
			# Handle Hand Rocket attack logic here
			print("Selected ability is Hand Rocket")
			var can_shoot = (not hand_ray_right.is_colliding() and not hand_ray_left.is_colliding()) or is_wall_sliding
			
			if can_shoot:
				if hand_instance == null and (not is_shooting or is_wall_sliding):
					if hand_scene == null:
						print("Hand scene not assigned!")
						return

					# Determine the shooting direction
					var shoot_direction = last_direction

					# Adjust shoot direction if wall sliding
					if is_wall_sliding:
						# If sliding against the right wall, shoot left
						if hand_ray_right.is_colliding():
							shoot_direction = -1
						# If sliding against the left wall, shoot right
						elif hand_ray_left.is_colliding():
							shoot_direction = 1

					# Set shooting state
					is_shooting = true
					is_hand_out = true  # Mark hand as out
					is_hand_flying = true

					# Only play the hand attack animation if NOT sliding
					if not is_wall_sliding:
						animation_player.play("handattack")  
						
					$Attack.play()

					# Instantiate and launch the hand
					hand_instance = hand_scene.instantiate()
					hand_instance.player = self
					hand_launch_offset = Vector2(20 * shoot_direction, -24)
					hand_instance.global_position = global_position + hand_launch_offset
					get_tree().current_scene.add_child(hand_instance)

					#if hand_instance.has_node("CollisionShape2D"):
						#hand_instance.get_node("CollisionShape2D").set_deferred("disabled", true)
						#var timer = Timer.new()
						#timer.wait_time = 0.01
						#timer.one_shot = true
						#timer.connect("timeout", Callable(self, "_on_hand_timer_timeout"))
						#add_child(timer)
						#timer.start()
					#else:
						#print("Error: 'CollisionShape2D' node not found in hand instance.")

					# Set the hand's direction to shoot away from the wall
					hand_instance.hand_direction = Vector2(shoot_direction, 0).normalized()
					hand_instance.hand_sprite.flip_h = shoot_direction < 0
					hand_instance.hand_returning = false

				elif hand_instance != null and not hand_returning:
					hand_returning = true
					hand_instance.set_hand_returning(true)

			# **NEW: Check for wall sliding to change hand status and animations**
			if is_wall_sliding:
				# Ensure hand is not out while sliding
				is_shooting = false  # Disable shooting while sliding
				
				# You may want to handle the animation change here
				if animation_player.current_animation != "hand_sliding":  # Use your sliding animation name
					animation_player.play("hand_sliding")  # Play sliding animation if not already playing
			else:
				# If not sliding, update the is_hand_out state for animations
				is_hand_out = true  # Set to true if the hand should be out when not sliding
				
				# **NEW: Check if the hand should be returning to normal**
				if animation_player.current_animation != "hand_normal":  # Use your normal state animation name
					animation_player.play("hand_normal")  # Play normal animation if not already playing

		elif selected_ability == "Left Hand":
			# Handle Left Hand attack logic here
			pass  # Replace with your actual attack logic

		elif selected_ability == "Right Leg":
			# Handle Right Leg attack logic here
			pass  # Replace with your actual attack logic

		elif selected_ability == "Left Leg":
			# Handle Left Leg attack logic here
			pass  # Replace with your actual attack logic

	if hand_instance != null:
		if is_hand_flying and not hand_returning:
			# Hand moves outward in the given direction
			hand_instance.position += hand_instance.hand_direction * hand_instance.hand_speed * delta
		elif hand_returning:
			# Hand returns back to the player
			var target_position = global_position + hand_launch_offset
			var direction_to_target = (target_position - hand_instance.global_position).normalized()
			hand_instance.position += direction_to_target * hand_instance.hand_speed * delta

			# Check if the hand has returned to the player
			if hand_instance.global_position.distance_to(target_position) < 10.0:
				hand_instance.queue_free()
				hand_instance = null
				hand_returning = false
				is_hand_out = false
				is_hand_flying = false  # Hand has successfully returned
				is_shooting = false
				play_animation("idle")


	move_and_slide()

func _on_hand_timer_timeout():
	if hand_instance and hand_instance.has_node("CollisionShape2D"):
		hand_instance.get_node("CollisionShape2D").set_deferred("disabled", false)

func _on_hand_body_entered(body):
	if hand_instance and not hand_returning:
		hand_returning = true
		hand_instance.set_hand_returning(true)
		is_hand_flying = false
		print("Hand collided with: ", body.name)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "handattack":
		is_shooting = false
		if is_on_floor():
			play_animation("idle")
		else:
			if velocity.y < 0:
				play_animation("jump_rise")
			elif velocity.y > 0:
				play_animation("jump_fall")
	elif is_wall_sliding:
		is_shooting = false

func play_animation(base_anim: String):
	var anim_suffix = "_nr" if is_hand_out else ""
	var full_anim_name = base_anim + anim_suffix
	animation_player.play(full_anim_name)

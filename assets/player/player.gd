extends CharacterBody2D

# Player States and Settings
var alive = true
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


var hit = false
var hit_timer = 0.5

var attack = false
var attack2 = false


# HP Bar & Healing Settings
@onready var hpbar: TextureRect = get_tree().get_first_node_in_group("hpbar")
@onready var hpbaranim: AnimationPlayer = get_tree().get_first_node_in_group("hpbaranim")
@onready var healing_timer: Timer = $HealingTimer
@export var hp = 100


# Audio and Ability Picker
@onready var audio_stream_player: AudioStreamPlayer = %bgm1

var current = 0

# Hand Attack & Crosshair
var haveHand = true
var jump = false
var wall = false
var walljump = false
var shootAnim = false
var canShoot = false
var isJumping = false
@export var hand_scene: PackedScene
@export var crosshair_scene: PackedScene
var crosshair_instance: Node2D = null
var dashScale = 5

# Initialization
func _ready() -> void:
	healing_timer.start()  # Start the healing timer
	hpbaranim.play("green")  # Return to normal animation if HP is restored
	add_to_group("hand_return")
	crosshair_instance = crosshair_scene.instantiate()
	get_parent().add_child.call_deferred(crosshair_instance)

# Main Game Loop
func _process(_delta: float) -> void:
	update_crosshair_position()
	handle_player_flip()
	handle_player_death()
	update_hp_bar_animation()
	update_hp_bar()
	update_player_animation()
	ability()
	
	

# Update crosshair position to follow mouse
func update_crosshair_position() -> void:
	if crosshair_instance:
		crosshair_instance.global_position = get_global_mouse_position()

# Handle player flip based on movement direction
func handle_player_flip() -> void:
	if velocity.x < 0 and !wall:
		$sprite.flip_h = true
	elif velocity.x > 0 and !wall:
		$sprite.flip_h = false

# Handle player death and reload scene if dead
func handle_player_death() -> void:
	if hp <= 0 and alive:
		alive = false
		print("Player died")
		var killzone = get_tree().get_first_node_in_group("killzone")
		if killzone and killzone.is_inside_tree():
			killzone.trigger_death()
		else:
			print("Killzone not found! Reloading normally.")
			Engine.time_scale = 0.5
			await get_tree().create_timer(1.0).timeout
			Engine.time_scale = 1
			get_tree().reload_current_scene()
	else:
		alive = true

# Update the HP bar animation based on current health
func update_hp_bar_animation() -> void:
	if hp <= 20:
		if hpbaranim.current_animation != "low" and hpbaranim.current_animation != "lowloop":
			hpbaranim.play("low")
			await hpbaranim.animation_finished
			hpbaranim.play("lowloop")
	else:
		if hpbaranim.current_animation != "green":
			hpbaranim.play("green")

# Update the HP bar's scale based on current health
func update_hp_bar() -> void:
	if hpbar:
		var tween = get_tree().create_tween()
		tween.tween_property(hpbar, "scale:x", hp * 0.01, 0.1)

# Update animations based on player state
func update_player_animation() -> void:
	if alive:
		if !jump and !wall and !shootAnim and !attack and !attack2:
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
		elif jump:
			if velocity.y < 0:
				play_animation("jump_rise")
			if velocity.y > 0:
				play_animation("jump_fall")
			if is_on_floor():
				jump = false
		elif wall:
			play_animation("wall")
		elif shootAnim:
			animation_player.play("handattack")
		elif attack:
			animation_player.play("jab")
		elif attack2:
			animation_player.play("jab2")

# Play specified animation based on current state
func play_animation(base_anim: String) -> void:
	if not animation_player:
		return
	var anim_suffix = "_nr" if !haveHand else ""
	var full_anim_name = base_anim + anim_suffix
	animation_player.play(full_anim_name)

# Physics Update (Player Movement)
func _physics_process(_delta: float) -> void:
	handle_gravity_and_movement()
	handle_jump_and_walljump()
	handle_wallslide_and_shooting()

	move_and_slide()

# Handle ability picker activation and deactivation


# Handle gravity, movement and wall sliding
func handle_gravity_and_movement() -> void:
	if !is_on_floor() and !wall:
		velocity.y += gravity

		# Faster fall when holding down (S key or down direction)
		if Input.get_action_strength("down"):  # Ensure "move_down" is mapped to the down direction (S key)
			velocity.y += gravity * 1.5  # You can tweak the multiplier to adjust how fast the fall is

	if is_on_floor():
		if previous_velocity_y > 450:
			$Land.play()
		wall = false
		isJumping = false
	
	previous_velocity_y = velocity.y

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
			velocity.x -= speed / 4.0
		if velocity.x < 0:
			velocity.x += speed / 4.0

# Handle jumping and wall jumping
func handle_jump_and_walljump() -> void:
	if Input.is_action_just_pressed("action_c"):
		if is_on_floor():
			$Jump.play()
			velocity.y = -jumpForce
			isJumping = true
		elif wall:
			velocity.y = -jumpForce
			velocity.x = maxSpeed * (1 if $left.is_colliding() else -1)
			walljump = false
			isJumping = true

	if isJumping and Input.is_action_just_released("action_c") and velocity.y < 0:
		velocity.y *= jump_hold_factor

# Handle wall sliding and shooting
func handle_wallslide_and_shooting() -> void:
	if !is_on_floor():
		if $left.is_colliding() or $right.is_colliding():
			wall = true
			canShoot = false
			if velocity.y < maxWallSpeed:
				velocity.y += wallSpeed
				walljump = true
		else:
			wall = false
			canShoot = true

	if walljump and Input.is_action_just_pressed("action_c"):
		walljump = false

	if haveHand and canShoot and Input.is_action_just_pressed("action_attack"):
		if crosshair_instance:
			crosshair_instance.get_node("AnimationPlayer").play("shoot")
		$Attack.play()
		
		match current:
			1:
				melee_attack()
			2:
				launch_hand()
			3:
				dash()
		

# Launch hand attack
func launch_hand() -> void:
	if not hand_scene:
		return
	haveHand = false
	shootAnim = true
	var launch_distance = 50.0
	var hand_instance = hand_scene.instantiate()
	hand_instance.hand_direction = (get_global_mouse_position() - global_position).normalized()
	var launch_position = global_position + hand_instance.hand_direction * launch_distance
	hand_instance.global_position = launch_position
	hand_instance.player = self
	get_parent().add_child(hand_instance)

# Handle hand return
func on_hand_returned() -> void:
	haveHand = true

# Reset shooting animation when it finishes
func _on_anim_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"handattack":
			shootAnim = false
		"jab":
			attack = false
		'jab2':
			attack2 = false

# Handle taking damage
func takehit(damage: int) -> void:
	hp -= damage
	hp = max(hp, 0)
	update_hp_bar()
	$Timer.start(hit_timer)
	$CPUParticles2D.emitting = true

	# Play animations based on HP threshold
	if hp <= 20:
		if hpbaranim.current_animation != "low" and hpbaranim.current_animation != "lowloop":
			hpbaranim.play("low")
			await hpbaranim.animation_finished
			hpbaranim.play("lowloop")
	else:
		if hpbaranim.current_animation != "green":
			hpbaranim.play("green")

# Healing timer callback
func _on_healing_timer_timeout() -> void:
	if hp < 100:
		hp += 0.2
		hp = min(hp, 100)
		update_hp_bar()

func ability():
	if $camera/pause.visible == false and $camera/ability.visible == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	if Input.is_action_pressed('action_pick'):
		$camera/ability.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Engine.time_scale = 0.1
		
	else:
		$camera/ability.visible = false
		Engine.time_scale = 1
	
	current = $camera/ability.current
	
func melee_attack():
	if $sprite.flip_h == true:
		$attack/CollisionShape2D.position.x = -30
	else:
		$attack/CollisionShape2D.position.x = 30
	
	# Всегда активируем коллайдер при атаке
	attack_colision()
	
	# Запускаем таймер для деактивации коллайдера
	$attack_timer.start()
	
	# Немедленная проверка столкновений
	var overlapping_bodies = $attack.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.name.begins_with('enemy'):
			body.getHit(10)
			# Наносим урон здесь

	# Переключение анимаций
	if !attack:
		attack = true
		animation_player.play("jab")
	else:
		attack = false
		attack2 = true
		animation_player.play("jab2")

func attack_colision():
	$attack/CollisionShape2D.disabled = false


func _on_timer_timeout() -> void:
	$CPUParticles2D.emitting = false


func _on_attack_body_entered(body: Node2D) -> void:
	if body.name.begins_with('enemy'):
		body.getHit(10)



func _on_attack_timer_timeout() -> void:
	$attack/CollisionShape2D.disabled = true


func dash():
	var dash_strength = 800  # Fixed dash speed
	var dash_direction = (get_global_mouse_position() - global_position).normalized()
	velocity = dash_direction * dash_strength  # Apply fixed speed
	
	create_dash_afterimage()  # Spawn afterimage during dash

	
func create_dash_afterimage():
	pass
	#for i in range(5):  # Create 5 afterimages
		#var afterimage = Sprite2D.new()
		#afterimage.texture = $sprite.texture  # Copy player sprite texture
		#afterimage.global_position = global_position
		#afterimage.scale = $sprite.scale
		#afterimage.rotation = $sprite.rotation
		#afterimage.flip_h = $sprite.flip_h
		#afterimage.flip_v = $sprite.flip_v
		#afterimage.modulate = Color(0, 0.5, 1, 0.7 - (i * 0.1))  # Blue tint with fading
		#afterimage.z_index = 10  # Ensure it's above most objects
		#get_parent().add_child(afterimage)  # Add to the same parent as the player
#
		## Tween to fade out and move slightly backward
		#var tween = get_tree().create_tween()
		#tween.tween_property(afterimage, "modulate:a", 0, 0.3 + (i * 0.05))  # Fade out
		#tween.tween_property(afterimage, "position", afterimage.position - velocity.normalized() * 10, 0.3)
#
		## Queue free after a short delay
		#await get_tree().create_timer(0.05).timeout
		#afterimage.queue_free()  # Remove after fadingvz

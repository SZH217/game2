extends RigidBody2D

@export var speed = 200
@export var maxSpeed = 200
var playerHere = false
@onready var player = $"../player"
var gravity = 20
var playerClose = false
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var spark: Node2D = $spark
@onready var sparkanim: AnimationPlayer = $spark/AnimationPlayer

@export var hp = 100

var backspeed = 5
var maxbackspeed = 100

@export var bullet: PackedScene
var can_shoot = true
var shooting = false  # Ensures shooting happens at intervals, not every frame

func _ready() -> void:
	anim.play("idle")
	spark.visible = false

func _process(_delta: float) -> void:
	if playerHere and playerClose:
		if not shooting:  
			shoot()
		sprite.flip_h = player.global_position.x > position.x
		return
	
	if hp <= 0:
		queue_free()
	
	if playerHere and not playerClose:
		if player.global_position.x > position.x:
			if linear_velocity.x < maxSpeed:
				linear_velocity.x += speed
				anim.play("run")
				sprite.flip_h = true
		elif player.global_position.x < position.x:
			if linear_velocity.x > -maxSpeed:
				linear_velocity.x -= speed
				anim.play("run")
				sprite.flip_h = false
	else:
		anim.play("idle")

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
	if not can_shoot:
		return
	
	can_shoot = false
	shooting = true  

	# Start animation immediately
	anim.play("aim")

	# Flip spark correctly around enemy center
	var flip_direction = -1 if sprite.flip_h else 1
	spark.scale.x = flip_direction
	
	# Adjust spark position relative to enemy center
	var offset_x = -28 # Adjust this value based on your enemy’s size
	spark.position.x = offset_x * flip_direction

	# Show spark and play its animation immediately
	spark.visible = true
	sparkanim.play("g")

	# Fire the bullet instantly when the first frame plays
	var bulletInst = bullet.instantiate()
	var direction = (player.global_position - global_position).normalized()
	var launch_position = global_position + direction * 40.0
	bulletInst.global_position = launch_position

	if bulletInst is RigidBody2D:
		bulletInst.linear_velocity = direction * 500
	
	get_parent().call_deferred("add_child", bulletInst)

	# Short delay to let the first frame of the animation play properly
	await get_tree().create_timer(0.05).timeout  
	anim.seek(anim.current_animation_length, true)  # Hold on last frame

	# Wait before allowing next shot
	await get_tree().create_timer(0.5).timeout
	can_shoot = true
	shooting = false  

func getHit(damage):
	hp -= damage
	print(hp)

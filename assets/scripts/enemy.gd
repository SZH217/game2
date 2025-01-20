extends RigidBody2D

@export var speed = 20
@export var maxSpeed = 200
var playerHere = false
@onready var player = $"../Player"
var gravity = 20
var playerClose = false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playerHere and !playerClose:
		if player.global_position.x > position.x:
			if linear_velocity.x < maxSpeed:
				linear_velocity.x += speed
		elif player.global_position.x < position.x:
			if linear_velocity.x > -maxSpeed:
				linear_velocity.x -= speed
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == ("Player"):
		playerHere = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == ("Player"):
		playerHere = false


func _on_close_area_body_entered(body: Node2D) -> void:
	if body.name == ("Player"):
		playerClose = true


func _on_close_area_body_exited(body: Node2D) -> void:
	if body.name == ("Player"):
		playerClose = false

extends CharacterBody2D

@export var speed = 5
@onready var player = $"../player"
var t = 0.04

var attack = false

@onready var pos = player.global_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Skeleton2D/left/Bone2D/Bone2D/Bone2D/Bone2D/hand.play("idle")
	$Skeleton2D/right/Bone2D/Bone2D/Bone2D/Bone2D/hand.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $Timer.is_stopped():
		$Timer.start(2)

func _physics_process(delta: float) -> void:
	position = position.lerp(player.position - Vector2(0, 140), t)
	
	if attack:
		var id = int(randf_range(1,4))
		print(id)
		match id:
			1:
				$hands.play("left attack")
				$tv.play("idle")
			2:
				$hands.play("right attack")
				$tv.play("eye")
			3:
				$hands.play("many")
				$tv.play("fire")
			4:
				$hands.play("saw")
				$tv.play("laugh")
		attack = false








func _on_timer_timeout() -> void:
	attack = true


func _on_right_body_entered(body: Node2D) -> void:
	if body.name == 'player':
		body.takehit(5)


func _on_left_body_entered(body: Node2D) -> void:
	if body.name == 'player':
		body.takehit(5)

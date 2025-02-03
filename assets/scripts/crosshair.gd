extends Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	anim.play("crosshair")
	anim.animation_finished.connect(_on_animation_finished)

func _process(_delta):
	# Keep the crosshair at the mouse position
	global_position = get_global_mouse_position()

func _on_animation_finished(anim_name: StringName):
	# Return to idle when shoot animation finishes
	if anim_name == "shoot":
		anim.play("crosshair")

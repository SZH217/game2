extends Control  # Base class for the ability picker UI

@onready var ability_left_hand = $AbilityLeftHand
@onready var ability_right_hand = $AbilityRightHand
@onready var ability_left_leg = $AbilityLeftLeg
@onready var ability_right_leg = $AbilityRightLeg

# Variable to keep track of the currently selected ability
var selected_ability_name: String = ""

func _ready() -> void:
	# Initialize other UI elements or states here if needed
	selected_ability_name = ""
	
	# We no longer need to connect signals, instead we'll update glob_vars directly
	# Example usage: GlobVars.selected_ability_name = selected_ability_name

# Mouse enter events for ability icons
func _on_ability_left_hand_mouse_entered() -> void:
	_sscale_sprite(ability_left_hand, 1.2)
	select_ability("Left Hand")
func _on_ability_left_hand_mouse_exited() -> void:
	_sscale_sprite(ability_left_hand, 1.0)
func select_ability(ability: String):
	GlobVars.selected_ability_name = ability
func _on_ability_right_hand_mouse_entered() -> void:
	_sscale_sprite(ability_right_hand, 1.2)
	select_ability("Hand Rocket")
func _on_ability_right_hand_mouse_exited() -> void:
	_sscale_sprite(ability_right_hand, 1.0)
func _on_ability_left_leg_mouse_entered() -> void:
	_sscale_sprite(ability_left_leg, 1.2)
	select_ability("Left Leg")
func _on_ability_left_leg_mouse_exited() -> void:
	_sscale_sprite(ability_left_leg, 1.0)
func _on_ability_right_leg_mouse_entered() -> void:
	_sscale_sprite(ability_right_leg, 1.2)
	select_ability("Right Leg")
func _on_ability_right_leg_mouse_exited() -> void:
	_sscale_sprite(ability_right_leg, 1.0)
# Helper function to scale the sprite
func _sscale_sprite(area: Area2D, scale: float) -> void:
	var sprite = area.get_child(0)
	sprite.scale = Vector2(scale, scale)  # Debugging output

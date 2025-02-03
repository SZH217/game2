extends Area2D

@onready var timer: Timer = $Timer
@onready var audio_stream_player: AudioStreamPlayer = %bgm1
@onready var fade_rect: ColorRect = get_tree().get_first_node_in_group("fade")

var target_pitch: float = 0.25
var lerp_duration: float = 0.5
var lerp_timer: float = 0.0
var is_pitch_decreasing: bool = false
var is_pitch_increasing: bool = false
var death_triggered: bool = false  # Prevent multiple calls

var fade_timer: float = 0.0
var fade_duration: float = 1.0  # Adjust this value for faster/slower fade

func trigger_death():
	if death_triggered:
		return  # Ignore if already triggered
	death_triggered = true  # Mark as triggered

	print("dead")
	Engine.time_scale = 0.5
	lerp_timer = 0.0
	is_pitch_decreasing = true
	fade_timer = 0.0
	timer.start()

	# Start fading out to black
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0  # Start with transparent
	lerp_fade(1.0)  # Fade to black

func lerp_fade(target_alpha: float) -> void:
	# Smoothly change the opacity of the fade rect (black screen)
	fade_rect.modulate.a = lerp(fade_rect.modulate.a, target_alpha, fade_timer / fade_duration)

func _on_timer_timeout() -> void:
	GlobVars.musicProgress = audio_stream_player.get_playback_position()
	get_tree().reload_current_scene()
	Engine.time_scale = 1
	lerp_timer = lerp_duration
	is_pitch_increasing = true
	death_triggered = false  # Reset for next time

	# Start fading back in
	fade_timer = 0.0
	lerp_fade(0.0)  # Fade back to transparent

func _process(delta: float) -> void:
	if is_pitch_decreasing:
		lerp_timer += delta
		if lerp_timer >= lerp_duration:
			lerp_timer = lerp_duration
			is_pitch_decreasing = false
			is_pitch_increasing = true

		audio_stream_player.pitch_scale = lerp(1.0, target_pitch, lerp_timer / lerp_duration)

	if is_pitch_increasing:
		lerp_timer -= delta
		if lerp_timer <= 0.0:
			lerp_timer = 0.0
			is_pitch_increasing = false

		audio_stream_player.pitch_scale = lerp(target_pitch, 1.0, 1.0 - (lerp_timer / lerp_duration))

	# Update fade timer to smoothly change the opacity
	if fade_timer < fade_duration:
		fade_timer += delta
		lerp_fade(fade_rect.modulate.a)  # Update the fade


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		trigger_death()

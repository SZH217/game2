extends Area2D

@onready var timer: Timer = $Timer
@onready var audio_stream_player: AudioStreamPlayer = %bgm1

var target_pitch: float = 0.25
var lerp_duration: float = 0.5
var lerp_timer: float = 0.0
var is_pitch_decreasing: bool = false
var is_pitch_increasing: bool = false

func _on_body_entered(body: CharacterBody2D) -> void:
	print("dead")
	Engine.time_scale = 0.5
	lerp_timer = 0.0
	is_pitch_decreasing = true
	body.get_node("colision").queue_free()
	timer.start()
	
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

func _on_timer_timeout() -> void:
	GlobVars.musicProgress = audio_stream_player.get_playback_position()
	get_tree().reload_current_scene()
	Engine.time_scale = 1
	lerp_timer = lerp_duration
	is_pitch_increasing = true

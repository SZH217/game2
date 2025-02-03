extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var bgm: AudioStreamPlayer = %bgm1

@export var detection_range: float = 150.0
@onready var player: CharacterBody2D = $"../player"

var is_playing = false

const BPM = 135.0
var frame_duration : float = 60.0 / BPM
var frames_per_beat = 2.0  # Set to 1 to play one frame per beat, or increase further if needed.

var is_nearby = false

var music_timer : Timer
var current_frame = 0

const sprite_width = 884
const sprite_height = 281
const num_frames = 4

var globvars = GlobVars # Ensure this points to the actual Globals instance

func _ready():
	music_timer = Timer.new()
	music_timer.wait_time = frame_duration * frames_per_beat
	music_timer.one_shot = false
	music_timer.autostart = false
	add_child(music_timer)
	music_timer.connect("timeout", Callable(self, "_on_music_timer_timeout"))
	
	update_frame(1)

	if player == null:
		print("Player node not found! Check the node path.")
	else:
		print("Player node is successfully assigned!")

	# Ensure globvars is not null before accessing it
	if globvars != null and globvars.is_music_playing:
		bgm.play()
		bgm.seek(globvars.musicProgress)  # Start the music from where it was left off
		music_timer.start()
		# Start the animation based on music progress
		update_animation_based_on_music()

func _process(_delta):
	if player != null:
		# Update is_nearby based on the player's position relative to the jukebox
		is_nearby = player.position.distance_to(position) <= detection_range

	# Only update animation if music is playing
	if globvars != null and globvars.is_music_playing:
		update_animation_based_on_music()

func update_animation_based_on_music():
	# Smooth frame calculation based on the music's playback position and BPM
	var playback_pos = bgm.get_playback_position()
	var beat_position = playback_pos / frame_duration  # Calculate beats elapsed
	var frame_position = int(beat_position * frames_per_beat) % num_frames  # Determine the current frame
	update_frame(frame_position)

func _input(_event):
	# Toggle music if the player is near and presses the interact button
	if is_nearby and Input.is_action_just_pressed("interact"):
		toggle_music()

func toggle_music():
	if is_playing:
		stop_music()
	else:
		start_music()

func start_music():
	bgm.play()
	is_playing = true
	music_timer.start()
	globvars.is_music_playing = true
	globvars.musicProgress = bgm.get_playback_position()  # Save the music progress

func stop_music():
	globvars.musicProgress = bgm.get_playback_position()  # Save the music progress
	bgm.stop()
	is_playing = false
	music_timer.stop()
	globvars.is_music_playing = false

func _on_music_timer_timeout():
	# Update frame based on music time
	if is_playing:
		update_animation_based_on_music()

func update_frame(frame_index: int):
	var frame_width = sprite_width / num_frames
	var frame_height = sprite_height
	var x_offset = frame_index * frame_width
	sprite.region_enabled = true
	sprite.region_rect = Rect2(x_offset, 0, frame_width, frame_height)

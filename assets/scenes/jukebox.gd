@tool
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var bgm: AudioStreamPlayer = %bgm1

@export var detection_range: float = 150.0
@onready var player: CharacterBody2D = $"../player"

var is_playing = false

const BPM = 135.0
var frame_duration : float = 60.0 / BPM
var frames_per_beat = 0.5

var is_nearby = false

var music_timer : Timer
var current_frame = 0

const sprite_width = 1105
const sprite_height = 281
const num_frames = 5

func _ready():
	music_timer = Timer.new()
	music_timer.wait_time = frame_duration * frames_per_beat
	music_timer.one_shot = false
	music_timer.autostart = false
	add_child(music_timer)
	music_timer.connect("timeout", Callable(self, "_on_music_timer_timeout"))
	
	update_frame(0)

	if player == null:
		print("Player node not found! Check the node path.")
	else:
		print("Player node is successfully assigned!")

func _process(_delta):
	if player != null:
		is_nearby = player.position.distance_to(position) <= detection_range

func _input(_event):
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
	update_frame(1)

func stop_music():
	bgm.stop()
	update_frame(0)
	is_playing = false
	music_timer.stop()

func _on_music_timer_timeout():
	if is_playing:
		current_frame += 1
		if current_frame >= num_frames:
			current_frame = 1
		update_frame(current_frame)

func update_frame(frame_index: int):
	var frame_width = sprite_width / num_frames
	var frame_height = sprite_height
	var x_offset = frame_index * frame_width
	sprite.region_enabled = true
	sprite.region_rect = Rect2(x_offset, 0, frame_width, frame_height)

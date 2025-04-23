extends Node

@onready var forest_music =  $ForestMusic
@onready var cave_music = $CaveMusic
@onready var pressure_music = $PressureMusic
@onready var boss_music = $BossMusic

var bg_music: AudioStreamPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bg_music = forest_music
	bg_music.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	bg_music.stream.loop_begin = 17 * 48000 # Its the second from where i want to start the loop times the mix rate
	bg_music.stream.loop_end = (bg_music.stream.get_length() - 1) * 48000
	play_music()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_track(new_track):
	bg_music = new_track
	bg_music.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	if new_track == forest_music:
		bg_music.stream.loop_begin = 17 * 48000 # Its the second from where i want to start the loop times the mix rate
		bg_music.stream.loop_end = (bg_music.stream.get_length() - 1) * 48000
	elif new_track == pressure_music:
		bg_music.stream.loop_begin = 17 * 48000 # Its the second from where i want to start the loop times the mix rate
		bg_music.stream.loop_end = (bg_music.stream.get_length() - 1) * 48000
	elif new_track == boss_music:
		bg_music.stream.loop_begin = 15 * 48000 # Its the second from where i want to start the loop times the mix rate
		bg_music.stream.loop_end = (bg_music.stream.get_length() - 1) * 48000
	elif new_track == cave_music:
		bg_music.stream.loop_begin = 1 * 48000 # Its the second from where i want to start the loop times the mix rate
		bg_music.stream.loop_end = (bg_music.stream.get_length() - 2) * 48000
	play_music()

func play_music():
	bg_music.play()

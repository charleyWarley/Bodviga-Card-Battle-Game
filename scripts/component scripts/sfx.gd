extends AudioStreamPlayer
class_name SFX

@export var target : Node2D

@export_group("Sounds")
@export var sound1 : AudioStream
@export var sound2 : AudioStream
@export var sound3 : AudioStream
@export var sound4 : AudioStream
@export var sound5 : AudioStream
@export var sound6 : AudioStream
@export var sound7 : AudioStream
@export var sound8: AudioStream



func _ready() -> void:
	connect_signals()


func connect_signals() -> void:
	pass


func play_sound(sound: AudioStream) -> void:
	set_stream(sound)
	play()

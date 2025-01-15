extends Node
class_name SFXComponent

@export var sound1 : AudioStream
@export var sound2 : AudioStream
@export var sound3 : AudioStream
@export var sound4 : AudioStream
@export var sound5 : AudioStream
@export var sound6 : AudioStream
@export var target : Node2D

var parent : AudioStreamPlayer


func _ready() -> void:
	parent = get_parent()
	connect_signals()


func connect_signals() -> void:
	pass


func play_sound(sound: AudioStream) -> void:
	parent.set_stream(sound)
	parent.play()

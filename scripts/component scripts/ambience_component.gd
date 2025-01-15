extends Node

@export var ambience_begin : AudioStream
@export var ambience_loop : AudioStream

var parent : AudioStreamPlayer


func _on_audio_finished() -> void:
	if parent.stream == ambience_begin:
		parent.set_stream(ambience_loop)
		print("ambience looped")
		parent.play()


func _ready() -> void:
	parent = get_parent()
	parent.set_stream(ambience_begin)
	parent.play()
	parent.connect("finished", Callable(self, "_on_audio_finished"))

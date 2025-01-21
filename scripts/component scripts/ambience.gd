extends AudioStreamPlayer

@export var ambience_begin : AudioStream
@export var ambience_loop : AudioStream


func _on_audio_finished() -> void:
	if stream == ambience_begin:
		set_stream(ambience_loop)
		disconnect("finished", Callable(self, "_on_audio_finished"))
		play()


func _ready() -> void:
	set_stream(ambience_begin)
	play()
	connect("finished", Callable(self, "_on_audio_finished"))

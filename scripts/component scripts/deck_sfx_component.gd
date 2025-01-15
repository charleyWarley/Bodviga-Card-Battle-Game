extends SFXComponent


func _on_card_drawn() -> void:
	parent.set_stream(sound1)
	parent.play()


func connect_signals() -> void:
	target.connect("card_drawn", Callable(self, "_on_card_drawn"))

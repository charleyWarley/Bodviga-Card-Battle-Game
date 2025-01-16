extends SFX


func _on_card_drawn() -> void:
	play_sound(sound1)


func connect_signals() -> void:
	target.connect("card_drawn", Callable(self, "_on_card_drawn"))

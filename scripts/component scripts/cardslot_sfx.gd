extends SFX

func _on_cardslot_filled() -> void:
	play_sound(sound1)


func connect_signals() -> void:
	target.connect("cardslot_filled", Callable(self, "_on_cardslot_filled"))

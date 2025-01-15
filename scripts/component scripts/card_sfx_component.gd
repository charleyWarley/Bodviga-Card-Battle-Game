extends SFXComponent


func _on_card_flipped() -> void:
	play_sound(sound3)


func _on_picked_up() -> void:
	play_sound(sound1)


func _on_returned_to_hand() -> void:
	play_sound(sound2)


func connect_signals() -> void:
	target.connect("picked_up", Callable(self, "_on_picked_up"))
	target.connect("returned_to_hand", Callable(self, "_on_returned_to_hand"))
	target.connect("card_flipped", Callable(self, "_on_card_flipped"))

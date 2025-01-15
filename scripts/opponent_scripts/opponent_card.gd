extends Card
class_name OpponentCard


func _ready() -> void:
	parent = get_parent()
	connect_signals()


func flip_card() -> void:
	if !is_in_play:
		set_sprite_image(card_small)
	else:
		if sprite.texture == card_back:
			set_sprite_image(card_small)
		else:
			set_sprite_image(card_back)


func connect_signals() -> void:
	connect("card_flipped", Callable(self, "_on_card_flipped"))
	connect("card_placed", Callable(self, "_on_card_placed"))
	connect("hand_position_updated", Callable(self, "_on_hand_position_updated"))
	connect("returned_to_hand", Callable(self, "_on_returned_to_hand"))

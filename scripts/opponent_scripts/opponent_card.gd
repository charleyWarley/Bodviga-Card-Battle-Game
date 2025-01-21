extends Card
class_name OpponentCard

func _ready() -> void:
	parent = get_parent()
	set_card_image(card_back, null)
	health_label.visible = false
	connect_signals()
	stats_labels.visible = false
	await get_tree().create_timer(0.1).timeout
	defense_label.text = str(defense)
	attack_label.text = str(power)



func flip_card() -> void:
	if !is_in_field:
		set_card_image(card_small, inside_small)
		stats_labels.visible = true
	else:
		if card_image.texture == card_back:
			set_card_image(card_small, inside_small)
			stats_labels.visible = true
		else:
			stats_labels.visible = true
			set_card_image(card_back, null)


func connect_signals() -> void:
	connect("card_flipped", Callable(self, "_on_card_flipped"))
	connect("card_placed", Callable(self, "_on_card_placed"))
	connect("hand_position_updated", Callable(self, "_on_hand_position_updated"))

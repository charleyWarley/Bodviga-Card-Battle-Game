extends Hand
class_name PlayerHand

@export var card_manager : CardManager

func calculate_card_position(index: int) -> float:
	var x_offset := (current_hand.size() - 1) * CARD_WIDTH
	var x_position := screen_center_x + index * CARD_WIDTH - x_offset / 2 ##draws card into the left side of the Hand
	return x_position

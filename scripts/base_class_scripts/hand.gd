extends Node2D
class_name Hand

@export var CARD_WIDTH : float
@export var HAND_Y_POSITION := 339

const REODER_SPEED := 0.2

var current_hand := []
var screen_center_x : float


func _ready() -> void:
	screen_center_x = 638 / 2


func add_to_hand(card: Card, speed: float) -> void:
	current_hand.insert(0, card)
	update_hand_positions(speed)


func update_hand_positions(speed:=REODER_SPEED):
	for i in range(current_hand.size()):
		var new_position := Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card : Card = current_hand[i]
		card.emit_signal("hand_position_updated", new_position, speed)
	


func remove_card_from_hand(card: Card) -> void:
	if card in current_hand:
		current_hand.erase(card)
		update_hand_positions()


func calculate_card_position(_index: int) -> float:
	return 0.0

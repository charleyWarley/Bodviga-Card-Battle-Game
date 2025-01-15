extends Node
class_name BattleManager

const TIME_TO_WAIT := 1.0

var empty_fighter_slots := []

@onready var end_turn_button := $"../EndTurnButton"
@onready var opponent_deck := $"../OpponentDeck"
@onready var opponent_hand := $"../OpponentHand"
@onready var player_deck := $"../PlayerDeck"
@onready var card_manager := $"../CardManager"

#called when the end turn button is pressed
func _on_player_turn_ended() -> void:
	start_opponent_turn()


func _ready() -> void:
	end_turn_button.connect("pressed", Callable(self, "_on_player_turn_ended"))
	empty_fighter_slots.append($"../CardSlots/EnemyCardSlot1")
	empty_fighter_slots.append($"../CardSlots/EnemyCardSlot2")
	empty_fighter_slots.append($"../CardSlots/EnemyCardSlot3")
	

func start_opponent_turn() -> void:
	end_turn_button.disabled = true
	end_turn_button.visible = false
	await get_tree().create_timer(TIME_TO_WAIT).timeout
	
	if opponent_deck.deck.size() > 0:
		opponent_deck.draw_card()
		await get_tree().create_timer(TIME_TO_WAIT).timeout
	
	if empty_fighter_slots.size() == 0:
		end_opponent_turn()
		return
	
	await find_best_card()
	
	end_opponent_turn()
	

func find_best_card() -> void:
	var opponent_current_hand : Array = opponent_hand.current_hand
	if opponent_current_hand.size() == 0:
		end_opponent_turn()
		return
	
	var random_empty_fighter_slot : CardSlot = empty_fighter_slots[
		randi_range(0, empty_fighter_slots.size() - 1)]
	empty_fighter_slots.erase(random_empty_fighter_slot)
	
	var best_card : OpponentCard = opponent_current_hand[0]
	for card in opponent_current_hand:
		if card.power > best_card.power:
			best_card = card
	best_card.animate_card_to_position(random_empty_fighter_slot.position)
	best_card.animation.play("flip")
	
	opponent_hand.remove_card_from_hand(best_card)
	
	await get_tree().create_timer(TIME_TO_WAIT).timeout


func end_opponent_turn() -> void:
	end_turn_button.disabled = false
	end_turn_button.visible = true
	player_deck.reset_draw()
	card_manager.reset_did_play_fighter_card()

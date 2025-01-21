extends Node2D
class_name Deck

signal card_drawn

@export var card_scene : PackedScene
@export var card_manager : CardManager
@export var hand : Hand

const DRAW_SPEED := 0.2
const STARTING_HAND_SIZE := 5

var deck := []
var was_turn_taken := false

@onready var card_database := preload("res://scripts/card_database.gd")


func _ready() -> void:
	connect_signals()
	await get_tree().create_timer(1).timeout
	initialize_deck()
	randomize()
	deck.shuffle()
	#await get_tree().create_timer(0.1).timeout
	for i in range(STARTING_HAND_SIZE):
		draw_card()
		was_turn_taken = false
		await get_tree().create_timer(0.1).timeout


func draw_card() -> void:
	if was_turn_taken or deck.size() == 0: return
	card_drawn.emit()
	was_turn_taken = true
	
	var drawn_card : String = deck[0]
	deck.erase(drawn_card)
	if deck.size() == 0:
		disable_deck()
	
	var new_card : Card = initialize_card(drawn_card)
	hand.add_to_hand(new_card, DRAW_SPEED)


func connect_signals() -> void:
	pass

func initialize_deck() -> void:
	pass

func initialize_card(_drawn_card: String) -> Card:
	return null

func disable_deck() -> void:
	pass

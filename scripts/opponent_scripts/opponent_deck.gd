extends Deck
class_name OpponentDeck


func initialize_deck() -> void:
	deck = [
		"ludra-cayn",
		"cure 1",
		"cure 1",
		"ludra-cayn",
		"kwartni",
		"bolsaht",
		"bolsaht",
		"bolsaht"
	]

func initialize_card(drawn_card: String) -> Card:
	var new_card : Card = card_scene.instantiate()
	card_manager.add_child(new_card)
	new_card.name = drawn_card
	new_card.power = card_database.CARDS[drawn_card][0]
	new_card.defense = card_database.CARDS[drawn_card][1]
	new_card.card_large = load(card_database.CARDS[drawn_card][2])
	new_card.card_type = card_database.CARDS[drawn_card][3]
	var card_small_path : String = new_card.card_large.get_path().replace("large", "small")
	new_card.card_small = load(card_small_path)
	#new_card.set_sprite_image(new_card.card_large)
	return new_card

extends Deck
class_name OpponentDeck


func initialize_deck() -> void:
	deck = [
		"bolsaht",
		"bolsaht",
		"bolsaht",
		"bolsaht",
		"kwartni",
		"ludra-cayn",
		"kettet"
	]

func initialize_card(drawn_card: String) -> Card:
	var new_card : Card = card_scene.instantiate()
	card_manager.add_child(new_card)
	new_card.name = drawn_card
	new_card.power = card_database.CARDS[drawn_card][0]
	new_card.defense = card_database.CARDS[drawn_card][1]
	new_card.health = 10
	new_card.inside_large = load(card_database.CARDS[drawn_card][2])
	new_card.card_type = card_database.CARDS[drawn_card][3]
	var inside_small_path : String = new_card.inside_large.get_path().replace("large", "small")
	new_card.inside_small = load(inside_small_path)
	return new_card


func disable_deck() -> void:
	visible = false

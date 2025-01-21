
enum CardType {FIGHTER, MAGIC, ITEM}

const CARDS := { #power/cost, defense, large card image path, card type
	"ludra-cayn": [7, 1, "res://images/card_images/ludra_cayn_large.png", CardType.FIGHTER],
	"bolsaht": [2, 2, "res://images/card_images/bolsaht_large.png", CardType.FIGHTER],
	"kwartni": [1, 8, "res://images/card_images/kwartni_large.png", CardType.FIGHTER],
	"kettet": [2, 4, "res://images/card_images/kettet_large.png", CardType.FIGHTER],
	
	"cure 1": [1, 0, "res://images/card_images/cure_large.png", CardType.MAGIC],
	"cure 2": [4, 0, "res://images/card_images/cure_large.png", CardType.MAGIC],
	"cure 3": [9, 0, "res://images/card_images/cure_large.png", CardType.MAGIC],
	"revive": [9, 0, "", CardType.MAGIC],
	"death touch": [8, 0, "", CardType.MAGIC],
	
	"enchanted book": [3, 0, "", CardType.ITEM]
}

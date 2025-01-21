extends Deck
class_name PlayerDeck

@onready var input_manager := $"../InputManager"
@onready var collision_shape := $Area2D/CollisionShape2D
@onready var sprite := $Sprite2D


func _on_deck_clicked() -> void:
	draw_card()


func initialize_deck() -> void:
	deck = [
	"ludra-cayn", 
	"cure 1", 
	"bolsaht", 
	"kwartni", 
	"ludra-cayn",
	"kwartni", 
	"ludra-cayn", 
	"kwartni"]


func initialize_card(drawn_card: String) -> Card:
	var new_card : Card = card_scene.instantiate()
	card_manager.add_child(new_card)
	new_card.name = drawn_card
	new_card.power = card_database.CARDS[drawn_card][0]
	new_card.defense = card_database.CARDS[drawn_card][1]
	new_card.health = 10
	new_card.card_large = load(card_database.CARDS[drawn_card][2])
	new_card.card_type = card_database.CARDS[drawn_card][3]
	var card_small_path : String = new_card.card_large.get_path().replace("large", "small")
	new_card.card_small = load(card_small_path)
	return new_card


func connect_signals() -> void:
	input_manager.connect("deck_clicked", Callable(self, "_on_deck_clicked"))


func reset_draw() -> void:
	was_turn_taken = false



func disable_deck() -> void:
	collision_shape.disabled = true
	sprite.visible = false

extends Node2D
class_name CardManager

const COLLISION_MASK_CARDSLOT := 0b010 #2 in decimal, 2 in the editor 2^1

var selected_fighter : Card
var moving_card : Card
var screen_size : Vector2
var did_play_fighter_card := false

@onready var player_hand := $"../PlayerHand"
@onready var input_manager := $"../InputManager"
@onready var battle_manager := $"../BattleManager"

##called when input manager emits lmb released signal
func _on_left_mouse_button_released() -> void:
	if moving_card:
		finish_drag()

##called when input manager emits card clicked signal
func _on_card_left_clicked(card: Card) -> void:
	if !card.is_in_field:
		start_drag(card)
		return
	if battle_manager.opponent_cards_in_field.size() == 0:
		battle_manager.direct_attack(card, "Player")
	else:
		select_card_for_battle(card)


func _on_card_right_clicked(card: Card) -> void:
	if card.is_in_field:
		card.emit_signal("card_flipped")


func _ready() -> void:
	screen_size = Vector2(638, 358)
	input_manager.connect("left_mouse_button_released", 
		Callable(self, "_on_left_mouse_button_released"))
	input_manager.connect("card_left_clicked", Callable(self, "_on_card_left_clicked"))
	input_manager.connect("card_right_clicked", Callable(self, "_on_card_right_clicked"))


func _physics_process(_delta: float) -> void:
	if !moving_card: return
	var mouse_position = get_global_mouse_position()
	moving_card.position = Vector2(
		clamp(mouse_position.x, 0, screen_size.x), 
		clamp(mouse_position.y, 0, screen_size.y)) 


func select_card_for_battle(card: Card) -> void:
	if selected_fighter:
		if selected_fighter == card:
			card.position.x -= 20
			selected_fighter = null
		else:
			selected_fighter = card
			selected_fighter.position.x -= 20
			card.position.x += 20
	else:
		selected_fighter = card
		card.position.x += 20


##called when a card is clicked and can be moved
func start_drag(card: Card) -> void:
	card.emit_signal("picked_up")
	moving_card = card
	card.z_index = 2
	card.scale = Vector2(1.1, 1.1)

##called when lmb is released when dragging a card; place card or return it to the hand
func finish_drag() -> void:
	moving_card.emit_signal("dropped")
	moving_card.scale = Vector2(1.05, 1.05)
	var cardslot_found := raycast_check_for_cardslot()
	if !cardslot_found:
		reject_move()
		return
	attempt_place_card(cardslot_found)


func attempt_place_card(cardslot: CardSlot) -> void:
	var is_move_rejected := check_move_rejected(cardslot)
	if is_move_rejected:
		reject_move()
		return
	place_card_in_slot(cardslot)


func check_move_rejected(cardslot: CardSlot) -> bool:
	var is_not_free_player_slot := (cardslot.is_slot_full or cardslot.is_opponent_cardslot)
	var is_not_matching := (moving_card.card_type != cardslot.slot_type)
	var cannot_place_fighter := (cardslot.slot_type == "fighter" and did_play_fighter_card)
	return (is_not_free_player_slot or is_not_matching or cannot_place_fighter)


##called when a card can be placed in a slot after lmb is released
func place_card_in_slot(cardslot: CardSlot) -> void:
	if cardslot.slot_type == "fighter":
		did_play_fighter_card = true
	cardslot.get_node("Area2D/CollisionShape2D").disabled = true ##make cardslot undetectable when moving other cards
	moving_card.animate_card_to_position(cardslot.position)
	cardslot.emit_signal("cardslot_filled")
	moving_card.emit_signal("card_placed")
	player_hand.remove_card_from_hand(moving_card)
	player_hand.update_hand_positions()
	cardslot.is_slot_full = true
	moving_card.current_cardslot = cardslot
	moving_card.connect("damage_taken", Callable(cardslot, "_on_damage_taken"))
	moving_card.connect("card_destroyed", Callable(cardslot, "_on_card_destroyed"))
	battle_manager.player_cards_in_field.append(moving_card)
	moving_card = null


##called when lmb is released to check for a cardslot
func raycast_check_for_cardslot() -> CardSlot:
	var space_state := get_world_2d().direct_space_state
	var parameters := PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARDSLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent() ##detects area2d child of cardslot and returns cardslot
	return null




##called when a card cannot be placed in a slot after lmb is released
func reject_move() -> void:
	moving_card.scale = Vector2(1.0, 1.0)
	moving_card.emit_signal("returned_to_hand")
	moving_card = null


func reset_did_play_fighter_card() -> void:
	did_play_fighter_card = false

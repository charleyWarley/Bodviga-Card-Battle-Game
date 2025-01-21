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

#called when input manager emits card clicked signal
func _on_card_left_clicked(card: Card) -> void:
	if !card.is_in_field:
		start_drag(card)
		return
	if !battle_manager.is_player_turn or check_card_unavailable(card): return
	if card.card_type == card.CardType.FIGHTER: 
		attempt_player_attack(card)
		return
	#if the card is magic or item card, apply click effect
	click_card(card)
	

func _on_card_right_clicked(card: Card) -> void:
	if card.is_in_field and card.card_type == card.CardType.FIGHTER:
		card.emit_signal("card_flipped")
	else:
		card.emit_signal("card_examined")


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


func check_card_unavailable(card: PlayerCard) -> bool:
	var is_card_unavailable : bool = card in battle_manager.player_cards_used_this_turn
	is_card_unavailable = is_card_unavailable or battle_manager.is_player_attacking
	return is_card_unavailable


func click_card(card: Card):
	card.highlight_card(false)
	await get_tree().create_timer(0.1).timeout
	card.highlight_card(true)


func attempt_player_attack(card: PlayerCard):
	if battle_manager.opponent_cards_in_field.size() == 0:
		#if there are no opponent cards, attack directly
		battle_manager.direct_attack(card, battle_manager.AttackerType.PLAYER)
	else:
		#if there are opponent cards, select card to attack
		select_card_for_battle(card)


func select_card_for_battle(card: Card) -> void:
	#if there's no selected fighter, make the card clicked the selected fighter
	if !selected_fighter: 
		selected_fighter = card
		card.position.x += 20
		return
	#if the selected fighter was clicked, deselect the fighter
	if card == selected_fighter:
		deselect_card()
	#if a card is selected but a new card was clicked, deselect the old card and select the new one
	else:
		deselect_card()
		selected_fighter = card
		card.position.x += 20


func deselect_card() -> void:
	if !selected_fighter: return
	selected_fighter.position.x -= 20
	selected_fighter = null


#called when a card is clicked and can be moved
func start_drag(card: PlayerCard) -> void:
	moving_card = card
	card.emit_signal("picked_up")
	card.make_small()
	card.z_index = 2
	card.scale = Vector2(1.1, 1.1)

#called when lmb is released when dragging a card; place card or return it to the hand
func finish_drag() -> void:
	moving_card.emit_signal("dropped")
	moving_card.scale = Vector2(1.05, 1.05)
	var cardslot_found := raycast_check_for_cardslot()
	if !cardslot_found or !battle_manager.is_player_turn:
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
	var is_not_free_player_slot := (
		cardslot.is_slot_full or cardslot.is_opponent_cardslot)
	var is_not_matching : bool = (moving_card.card_type != cardslot.SlotType)
	var cannot_place_fighter : bool = (
		cardslot.SlotType == moving_card.CardType.FIGHTER and did_play_fighter_card)
	return (is_not_free_player_slot or is_not_matching or cannot_place_fighter)


#called when a card can be placed in a slot after lmb is released
func place_card_in_slot(cardslot: CardSlot) -> void:
	if cardslot.SlotType == moving_card.CardType.FIGHTER:
		did_play_fighter_card = true
	cardslot.collision_shape.disabled = true ##make cardslot undetectable when moving other cards
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
	moving_card.emit_signal("returned_to_hand")
	moving_card = null


func reset_did_play_fighter_card() -> void:
	did_play_fighter_card = false

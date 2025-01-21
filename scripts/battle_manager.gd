extends Node
class_name BattleManager

enum AttackerType {PLAYER, OPPONENT}

@export var player_health_label : RichTextLabel
@export var opponent_health_label : RichTextLabel
@export var end_turn_button : Button
@export var opponent_deck : OpponentDeck
@export var opponent_hand : OpponentHand
@export var player_deck : PlayerDeck
@export var card_manager : CardManager
@export var player_discard_deck : Node2D
@export var opponent_discard_deck : Node2D

const SCREEN_WIDTH := 638
const BATTLE_POSITION_OFFSET := 15
const TIME_TO_WAIT := 1.0
const ATTACK_Z_INDEX := 5
const NON_ATTACK_Z_INDEX := 0
const DURATION := 0.3
const STARTING_HEALTH := 50

var empty_fighter_slots := []
var opponent_cards_in_field := []
var player_cards_in_field := []
var player_cards_used_this_turn := []
var player_health : int
var opponent_health : int
var is_player_turn := true
var is_player_attacking := false

#called when the end turn button is pressed
func _on_player_turn_ended() -> void:
	is_player_turn = false
	card_manager.deselect_card()
	player_cards_used_this_turn = []
	start_opponent_turn()


func _ready() -> void:
	end_turn_button.connect("pressed", Callable(self, "_on_player_turn_ended"))
	empty_fighter_slots.append($"../CardSlots/OpponentCardSlot1")
	empty_fighter_slots.append($"../CardSlots/OpponentCardSlot2")
	empty_fighter_slots.append($"../CardSlots/OpponentCardSlot3")
	initialize_health()


func initialize_health() -> void:
	player_health = STARTING_HEALTH
	set_player_health_label()
	opponent_health = STARTING_HEALTH
	set_opponent_health_label()


func start_opponent_turn() -> void:
	opponent_deck.was_turn_taken = false
	end_turn_button.disabled = true
	end_turn_button.visible = false
	await get_tree().create_timer(TIME_TO_WAIT).timeout
	
	#draw card if opponent deck has cards left
	if opponent_deck.deck.size() != 0:
		opponent_deck.draw_card()
		await get_tree().create_timer(TIME_TO_WAIT).timeout
	#end turn if there's no empty slot
	if empty_fighter_slots.size() != 0:
		#find card with highest attack to play from hand and play it
		await find_best_card()
	
	#if the opponent has cards on the field, attack player
	if opponent_cards_in_field.size() > 0:
		#create duplicate of available attack cards in playfield to loop through
		var attacking_opponent_cards := opponent_cards_in_field.duplicate()
		#each opponent attacks
		for card in attacking_opponent_cards:
			#if player has cards in the playfield, attack the cards
			if player_cards_in_field.size() > 0: 
				randomize()
				var defending_player_card : Card = player_cards_in_field.pick_random()
				await field_attack(card, defending_player_card, AttackerType.OPPONENT)
			else:
				#if the player has no cards in the playfield, attack the player directly
				await direct_attack(card, AttackerType.OPPONENT)
	end_opponent_turn()
	

func direct_attack(attacking_card: Card, attacker: AttackerType) -> void:
	attacking_card.z_index = ATTACK_Z_INDEX #render attacking card over everything else
	
	var new_position_x
	match attacker:
		AttackerType.OPPONENT: 
			new_position_x = 0 #opponent attacks left of screen
		AttackerType.PLAYER: 
			end_turn_button.disabled = true
			end_turn_button.visible = false
			is_player_attacking = true
			player_cards_used_this_turn.append(attacking_card)
			new_position_x = SCREEN_WIDTH #player attacks right of screen
	var new_position := Vector2(new_position_x, attacking_card.position.y)
	#tween to attack position
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(attacking_card, "position", new_position, DURATION)
	await get_tree().create_timer(0.3).timeout
	
	match attacker:
		AttackerType.OPPONENT: #deal damange to player
			player_health = max(0, player_health - attacking_card.power)
			set_player_health_label()
		AttackerType.PLAYER: #deal damage to opponent
			opponent_health = max(0, opponent_health - attacking_card.power)
			set_opponent_health_label()
	Global.crt.shake(abs(attacking_card.power)/2.0)
	#tween back to attack card's card slot position
	var tween2 := get_tree().create_tween()
	tween2.set_trans(Tween.TRANS_CUBIC)
	tween2.tween_property(attacking_card, "position", attacking_card.current_cardslot.position, DURATION)
	
	attacking_card.z_index = NON_ATTACK_Z_INDEX #return attack card to its original z position
	await get_tree().create_timer(1.0).timeout
	if attacker == AttackerType.PLAYER:
		is_player_attacking = false
		end_turn_button.disabled = false
		end_turn_button.visible = true


func field_attack(attacking_card: Card, defending_card: Card, attacker: AttackerType) -> void:
	match attacker:
		AttackerType.OPPONENT: pass
		AttackerType.PLAYER: 
			end_turn_button.disabled = true
			end_turn_button.visible = false
			is_player_attacking = true
			player_cards_used_this_turn.append(attacking_card)
	attacking_card.z_index = ATTACK_Z_INDEX
	
	#tween attacking card to the defending card and back
	var new_position = defending_card.position
	new_position.x += BATTLE_POSITION_OFFSET
	var tween := get_tree().create_tween()
	tween.tween_property(
		attacking_card, 
		"position", 
		new_position, 
		DURATION)
	await get_tree().create_timer(0.3).timeout
	var tween2 := get_tree().create_tween()
	tween2.tween_property(
		attacking_card, 
		"position", 
		attacking_card.current_cardslot.position, 
		DURATION)
	
	#defending card takes damage, attacking card takes half damage
	defending_card.take_damage(attacking_card.power - defending_card.defense , false)
	attacking_card.take_damage(defending_card.defense / 2, true)
	Global.crt.shake(abs(attacking_card.power - defending_card.defense) / 3.0)
	
	await get_tree().create_timer(1.0).timeout
	attacking_card.z_index = NON_ATTACK_Z_INDEX
	
	var card_was_destroyed := false
	#destroy card is health is 0
	if attacking_card.health <= 0:
		card_was_destroyed = true
		discard_card(attacking_card, attacker)
	if defending_card.health <= 0:
		match attacker:
			AttackerType.PLAYER: discard_card(defending_card, AttackerType.OPPONENT)
			AttackerType.OPPONENT: discard_card(defending_card, AttackerType.PLAYER)
		card_was_destroyed = true
		
	if card_was_destroyed:
		await get_tree().create_timer(1.0).timeout
	
	if attacker == AttackerType.PLAYER:
		end_turn_button.disabled = false
		end_turn_button.visible = true
		is_player_attacking = false
	

func discard_card(card_to_discard: Card, card_owner: AttackerType) -> void:
	#move card to discard deck
	card_to_discard.current_cardslot.is_slot_full = false
	card_to_discard.current_cardslot.collision_shape.disabled = false
	card_to_discard.is_in_field = false
	var new_position : Vector2
	match card_owner:
		AttackerType.PLAYER: 
			card_to_discard.collision_shape.disabled = true
			new_position = player_discard_deck.position
			if card_to_discard in player_cards_in_field:
				player_cards_in_field.erase(card_to_discard)
		AttackerType.OPPONENT: 
			new_position = opponent_discard_deck.position
			empty_fighter_slots.append(card_to_discard.current_cardslot)
			if card_to_discard in opponent_cards_in_field:
				opponent_cards_in_field.erase(card_to_discard)
	card_to_discard.current_cardslot.is_slot_full = false
	card_to_discard.current_cardslot = null
	var tween := get_tree().create_tween()
	tween.tween_property(card_to_discard, "position", new_position, DURATION)
	

func select_opponent_card(defending_card: OpponentCard) -> void:
	var attacking_card : PlayerCard = card_manager.selected_fighter
	if attacking_card and (defending_card in opponent_cards_in_field) and !is_player_attacking:
		card_manager.deselect_card() #deselects the attacking card
		field_attack(attacking_card, defending_card, AttackerType.PLAYER)
	

func find_best_card() -> void:
	var opponent_current_hand : Array = opponent_hand.current_hand
	if opponent_current_hand.size() == 0:
		return
	
	randomize()
	var random_empty_fighter_slot : CardSlot = empty_fighter_slots.pick_random()
	empty_fighter_slots.erase(random_empty_fighter_slot)
	
	var best_card : OpponentCard = opponent_current_hand[0]
	for card in opponent_current_hand:
		if card.power > best_card.power:
			best_card = card
	best_card.animate_card_to_position(random_empty_fighter_slot.position)
	best_card.emit_signal("card_flipped")
	best_card.connect("card_destroyed", Callable(random_empty_fighter_slot, "_on_card_destroyed"))
	
	opponent_hand.remove_card_from_hand(best_card)
	best_card.current_cardslot = random_empty_fighter_slot
	opponent_cards_in_field.append(best_card)
	await get_tree().create_timer(TIME_TO_WAIT).timeout


func return_to_slot(attacking_card: Card) -> void:
	var tween2 := get_tree().create_tween()
	tween2.tween_property(
		attacking_card, 
		"position", 
		attacking_card.current_cardslot.position, 
		DURATION)
	await get_tree().create_timer(1.0).timeout


func end_opponent_turn() -> void:
	#allow player to make another move#
	end_turn_button.disabled = false
	end_turn_button.visible = true
	player_deck.reset_draw() 
	card_manager.reset_did_play_fighter_card() 
	is_player_turn = true


func set_player_health_label() -> void:
	player_health_label.parse_bbcode("[center]" + str(player_health) + "[/center]")
	
	
func set_opponent_health_label() -> void:
	opponent_health_label.parse_bbcode("[center]" + str(opponent_health) + "[/center]")
	

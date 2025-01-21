extends Node2D

signal card_right_clicked(card: Card)
signal card_left_clicked(card: Card)
signal deck_clicked

#signal left_mouse_button_clicked
signal left_mouse_button_released

@export var battle_manager : BattleManager

const COLLISION_MASK_CARD := 0b001 #1 in decimal, 1 in the editor 2^0
const COLLISION_MASK_DECK := 0b100 #4 in decimal, 3 in the editor 2^2
#const COLLISION_MASK_OPPONENT_CARD := 0b1000

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			#left_mouse_button_clicked.emit()
			var left_clicked_card : Card = raycast_at_cursor()
			if left_clicked_card is PlayerCard:
				card_left_clicked.emit(left_clicked_card)
			elif left_clicked_card is OpponentCard:
				battle_manager.select_opponent_card(left_clicked_card)
		else:
			left_mouse_button_released.emit()
			await get_tree().create_timer(0.15).timeout
			var hovered_card : Card = raycast_at_cursor(true)
			if hovered_card is PlayerCard:
				hovered_card.highlight_card(true)
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			var right_clicked_card : Card = raycast_at_cursor(true)
			if right_clicked_card:
				card_right_clicked.emit(right_clicked_card)


func raycast_at_cursor(ignore_deck: bool= false) -> Card:
	var space_state := get_world_2d().direct_space_state
	var parameters := PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var result_collision_mask : int = result[0].collider.collision_mask
		if result_collision_mask == COLLISION_MASK_CARD:
			#card clicked
			var card_found : Card = result[0].collider.get_parent()
			return card_found
		elif result_collision_mask == COLLISION_MASK_DECK and !ignore_deck:
			#deck clicked

			deck_clicked.emit()
	return null

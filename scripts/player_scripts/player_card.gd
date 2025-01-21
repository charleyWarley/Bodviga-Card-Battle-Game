extends Card
class_name PlayerCard

signal hovered(card: Card)
signal unhovered
signal picked_up
signal dropped
signal size_changed(new_size)


var small_collision_size := Vector2(43, 60)
var large_collision_size := Vector2(66, 99)
var can_hover := false



func _on_returned_to_hand(duration:=DEFAULT_DURATION) -> void:
	make_large()
	scale = Vector2(1.0, 1.0)
	animate_card_to_position(hand_position, duration)


func _on_card_placed() -> void:
	z_index = 0
	is_in_field = true
	make_small()


func _on_mouse_entered() -> void:
	if parent.moving_card or !can_hover: return
	highlight_card(true)
	hovered.emit(self)


func _on_mouse_exited() -> void:
	if parent.moving_card or !can_hover: return
	highlight_card(false)
	unhovered.emit(self)


func _ready() -> void:
	collision_shape.shape.size = large_collision_size
	parent = get_parent()
	set_card_image(card_back, null)
	connect_signals()
	health_label.visible = false
	stats_labels.visible = false
	await get_tree().create_timer(0.1).timeout
	defense_label.text = str(defense)
	attack_label.text = str(power)
	card_flipped.emit()
	await get_tree().create_timer(0.5).timeout
	can_hover = true


func make_large() -> void:
	card_size = CardSize.LARGE
	set_card_image(card_large, inside_large)
	collision_shape.shape.size = large_collision_size
	size_changed.emit(card_size)


func make_small() -> void:
	set_card_image(card_small, inside_small)
	card_size = CardSize.SMALL
	size_changed.emit(card_size)
	collision_shape.shape.size = small_collision_size


func highlight_card(is_hovered: bool) -> void:
	if is_hovered:
		if !is_in_field:
			var tween := get_tree().create_tween()
			tween.tween_property(self, "position", Vector2(return_position_x, 339-33), 0.1)
		else:
			scale = Vector2(1.05, 1.05)
		z_index = 2
	else:
		if !is_in_field:
			await get_tree().create_timer(0.1).timeout
			var tween := get_tree().create_tween()
			tween.tween_property(self, "position", Vector2(return_position_x, 339), 0.1)
		else:
			scale = Vector2(1.0, 1.0)
		z_index = 0


func flip_card() -> void:
	if !is_in_field:
		stats_labels.visible = true
		set_card_image(card_large, inside_large)
	else:
		if card_image.texture == card_small:
			stats_labels.visible = false
			set_card_image(card_back, null)
		else:
			stats_labels.visible = true
			set_card_image(card_small, inside_small)
			


func connect_signals() -> void:
	area.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	area.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	connect("card_flipped", Callable(self, "_on_card_flipped"))
	connect("card_examined", Callable(self, "_on_card_examined"))
	connect("card_placed", Callable(self, "_on_card_placed"))
	connect("hand_position_updated", Callable(self, "_on_hand_position_updated"))
	connect("returned_to_hand", Callable(self, "_on_returned_to_hand"))

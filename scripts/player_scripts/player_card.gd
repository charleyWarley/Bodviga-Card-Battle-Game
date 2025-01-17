extends Card
class_name PlayerCard

signal hovered(card: Card)
signal unhovered
@warning_ignore("unused_signal")
signal picked_up
@warning_ignore("unused_signal")
signal dropped

@export var area : Area2D

var small_collision_size := Vector2(43, 60)
var large_collision_size := Vector2(74, 104)

@onready var collision_shape := $Area2D/CollisionShape2D


func _on_returned_to_hand(duration:=DEFAULT_DURATION) -> void:
	animate_card_to_position(hand_position, duration)


func _on_card_placed() -> void:
	z_index = 0
	is_in_field = true
	sprite.texture = card_small
	collision_shape.shape.size = small_collision_size


func _on_mouse_entered() -> void:
	if parent.moving_card: return
	highlight_card(true)
	hovered.emit(self)


func _on_mouse_exited() -> void:
	if parent.moving_card: return
	highlight_card(false)
	unhovered.emit(self)


func _ready() -> void:
	collision_shape.shape.size = large_collision_size
	parent = get_parent()
	animation.play("flip")
	connect_signals()


func highlight_card(is_hovered: bool) -> void:
	if is_hovered:
		scale = Vector2(1.05, 1.05)
		z_index = 2
	else:
		scale = Vector2(1.0, 1.0)
		z_index = 0


func flip_card() -> void:
	if !is_in_field:
		set_sprite_image(card_large)
	else:
		if sprite.texture == card_small:
			set_sprite_image(card_back)
		else:
			set_sprite_image(card_small)


func connect_signals() -> void:
	area.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	area.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	connect("card_flipped", Callable(self, "_on_card_flipped"))
	connect("card_placed", Callable(self, "_on_card_placed"))
	connect("hand_position_updated", Callable(self, "_on_hand_position_updated"))
	connect("returned_to_hand", Callable(self, "_on_returned_to_hand"))

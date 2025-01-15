extends Node2D
class_name Card

@warning_ignore("unused_signal")
signal card_placed
@warning_ignore("unused_signal")
signal hand_position_updated
@warning_ignore("unused_signal")
signal returned_to_hand
@warning_ignore("unused_signal")
signal card_flipped
signal card_destroyed(card: Card)
signal damage_taken(health_remaining: int, is_attacker: bool)

@export var sprite : Sprite2D

const DEFAULT_DURATION := 0.1

var is_in_field := false
var card_large : CompressedTexture2D
var card_small : CompressedTexture2D
var card_type : String
var current_cardslot : CardSlot = null
var parent : CardManager
var hand_position : Vector2
var power : int
var defense : int
var health : int
var starting_position : Vector2

@onready var card_back := preload("res://images/card_images/card_back.png")
@onready var animation := $Sprite2D/AnimationPlayer


func _on_returned_to_hand(duration:=DEFAULT_DURATION) -> void:
	animate_card_to_position(hand_position, duration)

##called when Hand updates card positions and emits signal
func _on_hand_position_updated(new_position: Vector2, duration:=DEFAULT_DURATION) -> void:
	hand_position = new_position
	animate_card_to_position(new_position, duration)


func _on_card_flipped() -> void:
	animation.play("flip")


func animate_card_to_position(new_position: Vector2, duration:float=DEFAULT_DURATION) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(
		self, 
		"position", new_position,
		duration)


func set_sprite_image(image: CompressedTexture2D) -> void:
	sprite.set_texture(image)


func take_damage(damage: int, is_attacker: bool):
	health -= damage
	if health <= 0:
		card_destroyed.emit(self)
		await get_tree().create_timer(1.0).timeout
		#queue_free()
		return
	damage_taken.emit(health, is_attacker)


func flip_card() -> void:
	pass



func connect_signals() -> void:
	pass
 

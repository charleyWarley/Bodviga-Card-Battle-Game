extends Node2D
class_name CardSlot

signal cardslot_filled

@export_enum("FIGHTER", "MAGIC", "ITEM") var SlotType : int
@export var is_opponent_cardslot := false
@export var image : CompressedTexture2D
@export var collision_shape : CollisionShape2D

var is_slot_full := false

@onready var sprite := $Sprite2D


func _on_card_destroyed(card: Card) -> void:
	if !is_opponent_cardslot: card.disconnect("damage_taken", Callable(self, "_on_damage_taken"))
	card.disconnect("card_destroyed", Callable(self, "_on_card_destroyed"))
	is_slot_full = false
	print("slot emptied")


func _ready() -> void:
	sprite.texture = image
	if is_opponent_cardslot: collision_shape.disabled = true
